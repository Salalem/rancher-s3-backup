FROM alpine:3.8

# Define environment variables.
ENV PROJECT_NAME "rancher-s3-backup"
ENV WORKSPACE_PATH "/workspace"
ENV PROJECT_PATH $WORKSPACE_PATH/$PROJECT_NAME

# Install dependencies
RUN apk add dcron python py-pip py-setuptools git ca-certificates

# Install necessary python packages
RUN pip install python-dateutil

# Get s3cmd
RUN git clone https://github.com/s3tools/s3cmd.git /opt/s3cmd
RUN ln -s /opt/s3cmd/s3cmd /usr/bin/s3cmd

# Make necessary directories and links for dcron
RUN mkdir -p \
    /opt/cron/periodic \
    /opt/cron/crontabs \
    /opt/cron/cronstamps && \
    ln -sf /dev/pts/0 /opt/cron/stdout && \
    ln -sf /dev/pts/0 /opt/cron/stderr

# Add execute script to bin, and create crontab in the appropriate path
ADD execute /usr/bin/
ADD crontab /opt/cron/crontabs/root

# Copy all files from host to build context
WORKDIR $PROJECT_PATH
COPY . .

# Grant 'R-X' permissions to the backup script
RUN chmod -R u+rx $PROJECT_PATH/run-backup.sh


RUN mkdir ~/rancher-data
# Run
ENTRYPOINT ["/workspace/rancher-s3-backup/entrypoint.sh"]
CMD ["cron"]
