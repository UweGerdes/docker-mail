# mail docker with SMTP, POP3, IMAP, alpine client

FROM uwegerdes/baseimage
MAINTAINER Uwe Gerdes <entwicklung@uwegerdes.de>

ARG USERNAME='testbox'
ARG PASSWORD='testpass'

ENV USERNAME=${USERNAME}
ENV TERM=xterm

RUN apt-get update && \
	apt-get install -y \
					alpine \
					bsd-mailx \
					dovecot-imapd \
					dovecot-lmtpd \
					dovecot-pop3d \
					postfix && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
	echo "root:${USERNAME}" >> /etc/aliases && \
	newaliases && \
	mkdir -p /home/${USERNAME} && \
	useradd --shell /bin/bash --home /home/${USERNAME} ${USERNAME} && \
	chown ${USERNAME}:${USERNAME} /home/${USERNAME} && \
	adduser ${USERNAME} mail && \
	echo "${USERNAME}:${PASSWORD}" | chpasswd && \
	sed -i \
		-e 's/#disable_plaintext_auth = yes/disable_plaintext_auth = no/' \
		-e 's/#auth_username_format = %Lu/auth_username_format = %Ln/' \
		/etc/dovecot/conf.d/10-auth.conf && \
	sed -i \
		-e 's/#log_path = syslog/log_path = \/var\/log\/dovecot.err/' \
		-e 's/#info_log_path = /info_log_path = \/var\/log\/dovecot.log/' \
		-e 's/#debug_log_path = /debug_log_path = \/var\/log\/dovecot.log/' \
		-e 's/#mail_debug = no/mail_debug = yes/' \
		/etc/dovecot/conf.d/10-logging.conf && \
	sed -i \
		-e 's/mail_privileged_group =/#mail_privileged_group =/' \
		/etc/dovecot/conf.d/10-mail.conf && \
	sed -i \
		-E 's/  unix_listener lmtp \{/  unix_listener \/var\/spool\/postfix\/private\/dovecot-lmtp {\n    group = postfix\n    mode = 0600\n    user = postfix/g' \
		/etc/dovecot/conf.d/10-master.conf && \
	sed -i \
		-e 's/ssl = yes/ssl = no/' \
		/etc/dovecot/conf.d/10-ssl.conf && \
	sed -i \
		-E 's/protocol lmtp \{/protocol lmtp {\n  postmaster_address = postmaster@localhost/' \
		/etc/dovecot/conf.d/20-lmtp.conf && \
	sed -i -e 's/(lmtp\s+unix\s+-\s+-\s+)-(\s+-\s+-\s+lmtp)/$1n$2/g' /etc/postfix/master.cf

COPY /conf/start.sh /start.sh
RUN chmod a+x /start.sh
COPY postfix/ /etc/postfix/
COPY alpine/pinerc /home/${USERNAME}/.pinerc
RUN chown ${USERNAME}:${USERNAME} /home/${USERNAME}/.pinerc

EXPOSE 25 110 143

CMD ["/start.sh"]

