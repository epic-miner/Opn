# Use the existing openvpn image as the base image
FROM alekslitvinenk/openvpn

# Install curl
RUN apt-get update && apt-get install -y curl

# Set environment variable for HOST_ADDR
ENV HOST_ADDR=$(curl -s https://api.ipify.org)

# Expose the necessary ports
EXPOSE 1194/udp 8080/tcp

# Set the entrypoint
ENTRYPOINT ["sh", "-c", "openvpn --config /opt/Dockovpn_data/config.ovpn"]
