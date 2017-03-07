# Docker uwegerdes/mail

For testing my application I need a small mail server that accepts smtp mail for user testbox and delivers it via imap.

The application is configured to use hostname mail.local.

## Build

Build the image with (mind the dot):

```bash
$ docker build -t uwegerdes/mail .
```

## Usage

Run the mail container with:

```bash
$ docker run -d \
	--hostname mail.local \
	--name mail \
	uwegerdes/mail
```

To see what is happening there you might want to:

```bash
$ docker exec -it mail gosu testbox alpine
$ docker exec -it mail tail -f /var/log/dovecot.log
$ docker exec -it mail bash
```

Alpine is a simple mail client, if you started test-forms-login from the `uwegerdes/frontend-development` container you should find the mails. See the project on github.

Hit CTRL-C to stop the tail command and CTRL-D to exit the bash.
