FROM zeropain/arch-int-vpn-arm64:latest
LABEL maintainer="github.com/zeropain"

# additional files
##################

# add supervisor conf file for app
ADD build/*.conf /etc/supervisor/conf.d/

# add bash/python scripts to install app
ADD build/root/*.sh /root/
ADD build/root/*.py /root/

# add bash script to setup iptables
ADD run/root/*.sh /root/

# add bash script to run deluge
ADD run/nobody/*.sh /home/nobody/

# add python script to configure deluge
ADD run/nobody/*.py /home/nobody/

# add pre-configured config files for deluge
ADD config/nobody/ /home/nobody/

# add webui theme
ADD build/root/webui /root/webui

# install app
#############

# make executable and run bash scripts to install app
RUN chmod +x /root/*.sh /home/nobody/*.sh /home/nobody/*.py && \
	/bin/bash /root/install.sh && \
	python /root/fix_deluge_plugins.py

# copy webui theme
RUN python -c "import os; import site; print(os.path.join(site.getsitepackages()[0], 'deluge', 'ui', 'web'))" \
	| sed 's/.*/"&"/' | xargs cp -r /root/webui/* && rm -rf /root/webui

# docker settings
#################

# map /config to host defined config path (used to store configuration from app)
VOLUME /config

# map /data to host defined data path (used to store data from app)
VOLUME /data

# expose port for deluge webui
EXPOSE 8112

# expose port for privoxy
EXPOSE 8118

# expose port for deluge daemon (used in conjunction with LAN_NETWORK env var)
EXPOSE 58846

# expose port for deluge incoming port (used only if VPN_ENABLED=no)
EXPOSE 58946
EXPOSE 58946/udp

# set permissions
#################

# run script to set uid, gid and permissions
CMD ["/bin/bash", "/usr/local/bin/init.sh"]
