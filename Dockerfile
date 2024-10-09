# Use the latest official Ubuntu image
FROM ubuntu:latest

# Update packages and install necessary tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server \
    sudo \
    curl \
    vim \
    net-tools \
    htop \
    ca-certificates \
    wget && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install ngrok
RUN wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz && \
    tar xvzf ngrok-v3-stable-linux-amd64.tgz -C /usr/local/bin && \
    rm ngrok-v3-stable-linux-amd64.tgz

# Set up ngrok
RUN ngrok config add-authtoken 2nDRUrng2e2EYbiEgF4yevEHKjE_4a3JwKEHkwqq3uNC8sGzJ

# Create the necessary directory for SSH daemon
RUN mkdir -p /var/run/sshd

# Create a new user with sudo privileges or update existing user
RUN if id "ubuntu" &>/dev/null; then \
        echo "ubuntu:password" | chpasswd && \
        usermod -aG sudo ubuntu; \
    else \
        useradd -m -d /home/ubuntu -s /bin/bash ubuntu && \
        echo "ubuntu:password" | chpasswd && \
        usermod -aG sudo ubuntu; \
    fi

# Set up SSH key authentication (replace with your actual public key)
RUN mkdir -p /home/ubuntu/.ssh && \
    chmod 700 /home/ubuntu/.ssh && \
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCY+mVtC8D7nPXQMmyl21gN6HSsMLA4duDg75kuuQf1hRDFT90py08U+74xRww9Sac4HWLBJHzpoFB4/AT0Obr6P/m/R7PSubwRIQ9/s0gD0wxkX/1ViftGuNn0YN2ZtobjJ+fKru0nSPSToRIachIKm+SwKyxDANk1eFRiYKa7YnNRbdBn2omlDrki++SY63fCto4VmRmYWu+xDZw8b7DQt15h+qy74q1Iwv14kPXDeaVtQgPd/97y6obXMYAncKM7X6IlS+hUrHwZm9mtNAbcApgepDwkIs7fTsQEkJ15+jbPtZ5cMjoXv71vWHy+vUqj+BwweJAa3afj1boO7iUkcPwzpHm8eRAw2Bt11ySFHdSkodFTM9xbBrSDLlVfrpzJh1yU74CvTZxtHiYNcNSzbM9RxqzZcJhcFHHmu4UV9ekmSFHhagjA0rzY82HYYBmpW42RLPuLrq6ExnEM//3+sUiyUxymToBLXTdnI+lDTJbS3PMv8DC+Th9OdIgj1ZsM53nJ57AGfZ8F0QjojuQZkydgoJEFtmhjFSfQHSVC+J0SBS+11zCkA5RoUh6lA9UvPidBk0iQF6wgMIJaEchk4TwrFAqlV+fwF8gntrJyj9Epc8Y9IsGkG3IE+l+Bf2uq79Co5hdu616FDGy8cnKzZ7SJfeg7/2YNpIB6JAZF3w==" > /home/ubuntu/.ssh/authorized_keys && \
    chmod 600 /home/ubuntu/.ssh/authorized_keys && \
    chown -R ubuntu:ubuntu /home/ubuntu/.ssh

# Allow SSH password authentication and root login (optional, for initial setup)
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Expose port 22 for SSH access
EXPOSE 22

# Start SSH service and ngrok
CMD service ssh start && ngrok tcp 22
