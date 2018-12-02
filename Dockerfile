FROM zachgray/swift-tensorflow:4.2

LABEL Description="An STS Application"

WORKDIR /usr/src

RUN apt-get update && apt-get install inotify-tools -y

# Cache this step
COPY Package.swift /usr/src
RUN swift package update

# Add Source
ADD ./ /usr/src

# user can pass in CONFIG=release to override
ENV CONFIG=debug

# user can pass in LIVE=true
ENV LIVE=false

RUN swift build -Xswiftc -O --configuration ${CONFIG}

RUN cp ./.build/${CONFIG}/alpha-go-zero-swift /usr/bin/alpha-go-zero-swift

ENTRYPOINT ./entrypoint $CONFIG $LIVE
