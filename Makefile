include make.d/*

build:
	docker build -t $(DOCKERPREFIX)development .

install: check-nginx check-developer check-port check-key
	docker run -d --name=$(NAMESPACE)-development-$(DEVELOPER) -e "DEVELOPER=$(DEVELOPER)" -e "KEY=$(KEY)" --volumes-from $(NAMESPACE)-nginx --link $(NAMESPACE)-mariadb:mariadb -p $(SSHPORT):22 -v /home/$(DEVELOPER)/volumes/workspace $(DOCKERPREFIX)development
	docker exec $(NAMESPACE)-development-$(DEVELOPER) /bin/bash -c "chmod +x /start.sh && /start.sh && rm /start.sh"
	docker stop $(NAMESPACE)-development-$(DEVELOPER)
	sudo cp systemd/$(NAMESPACE)-development-developer.service.tmpl $(SYSTEMDSERVICEFOLDER)$(NAMESPACE)-development-$(DEVELOPER).service
	sudo sed -i s/$(DEVELOPERPLACEHOLDER)/$(DEVELOPER)/g $(SYSTEMDSERVICEFOLDER)$(NAMESPACE)-development-$(DEVELOPER).service
	sudo sed -i s/$(NAMESPACEPLACEHOLDER)/$(NAMESPACE)/g $(SYSTEMDSERVICEFOLDER)$(NAMESPACE)-development-$(DEVELOPER).service
	sudo sed -i s/--volumes-from\ $(NAMESPACE)-development-$(DEVELOPER)\ //g $(SYSTEMDSERVICEFOLDER)$(NAMESPACE)-nginx.service.d/EnvironmentFile
	sudo sed -i s/VOLUMESFROM=/VOLUMESFROM=--volumes-from\ $(NAMESPACE)-development-$(DEVELOPER)\ /g $(SYSTEMDSERVICEFOLDER)$(NAMESPACE)-nginx.service.d/EnvironmentFile
	sudo sed -i s/VOLUMESFROM=/VOLUMESFROM=--volumes-from\ $(NAMESPACE)-development-$(DEVELOPER)\ /g $(SYSTEMDSERVICEFOLDER)$(NAMESPACE)-php-fpm.service.d/EnvironmentFile
	sudo systemctl enable $(NAMESPACE)-development-$(DEVELOPER).service
	sudo systemctl restart $(NAMESPACE)-nginx

run: check-developer
	sudo systemctl start $(NAMESPACE)-development-$(DEVELOPER)

uninstall: check-developer
	-sudo systemctl stop $(NAMESPACE)-development-$(DEVELOPER)
	-sudo systemctl disable $(NAMESPACE)-development-$(DEVELOPER)
	-sudo sed -i s/--volumes-from\ $(NAMESPACE)-development-$(DEVELOPER)\ //g $(SYSTEMDSERVICEFOLDER)$(NAMESPACE)-nginx.service.d/EnvironmentFile
	-docker stop $(NAMESPACE)-development-$(DEVELOPER)
	-docker rm $(NAMESPACE)-development-$(DEVELOPER)

check-developer:
	if [ -z $(DEVELOPER) ]; then echo ">>> please define DEVELOPER"; exit 1; fi

check-port:
	if [ -z $(SSHPORT) ]; then echo ">>> please define SSHPORT"; exit 1; fi

check-key:
	if [ -z "$(KEY)" ]; then echo ">>> please define KEY"; exit 1; fi

check-nginx:
	if [ !-f /etc/systemd/system/$(NAMESPACE)-nginx.service.d/EnvironmentFile ]; then echo ">>> please make sure the nginx container is running"; exit 1; fi
