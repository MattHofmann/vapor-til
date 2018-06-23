# Use the Swift 4.1 image
FROM swift:4.1

# Set the working directory to /package. 
WORKDIR /package

# Copy the contents of the current directory into /package in the container.
COPY . ./

# Fetch the dependencies and clean up the project’s build artifacts.
RUN swift package resolve
RUN swift package clean

# Set the default command to swift test. This is the command Docker executes when you run the Dockerfile.
CMD ["swift", "test"]