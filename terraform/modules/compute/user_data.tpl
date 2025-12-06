#cloud-config
runcmd:
  - echo "===== USER DATA STARTED =====" > /var/log/user-data.log
  - echo "Updating apt repos..." >> /var/log/user-data.log
  - apt-get update -y >> /var/log/user-data.log 2>&1

  # Install AWS CLI using snap (correct for Ubuntu 24.04)
  - echo "Installing AWS CLI..." >> /var/log/user-data.log
  - snap install aws-cli --classic >> /var/log/user-data.log 2>&1

  - mkdir -p /opt/assignment

  # Download your Go binary from S3
  - echo "Downloading Go app from S3..." >> /var/log/user-data.log
  - aws s3 cp s3://${bucket}/${key} /opt/assignment/assignment-app --region ${region} >> /var/log/user-data.log 2>&1

  - chmod +x /opt/assignment/assignment-app

  # Create systemd service
  - |
      cat >/etc/systemd/system/assignment-app.service <<EOF
      [Unit]
      Description=Go Assignment App
      After=network.target

      [Service]
      ExecStart=/opt/assignment/assignment-app
      Restart=always
      User=root

      [Install]
      WantedBy=multi-user.target
      EOF

  - systemctl daemon-reload
  - systemctl enable assignment-app
  - systemctl start assignment-app
  - echo "===== USER DATA COMPLETED =====" >> /var/log/user-data.log
