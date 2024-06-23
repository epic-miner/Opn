# Use an official Ubuntu as a parent image
FROM ubuntu:20.04

# Set environment variables to non-interactive to suppress prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && \
    apt-get install -y openvpn easy-rsa iproute2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set up easy-rsa
RUN make-cadir /etc/openvpn/easy-rsa
WORKDIR /etc/openvpn/easy-rsa
RUN ./easyrsa init-pki

# Copy a script to initialize OpenVPN configuration
COPY init-openvpn.sh /etc/openvpn/init-openvpn.sh
RUN chmod +x /etc/openvpn/init-openvpn.sh

# Expose the OpenVPN port
EXPOSE 1194/udp

# Set the entry point to run OpenVPN
ENTRYPOINT ["/etc/openvpn/init-openvpn.sh"]
CMD ["openvpn", "--config", "/etc/openvpn/server.conf"]
