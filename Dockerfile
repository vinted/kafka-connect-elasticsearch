FROM maven:3.6.3-jdk-11 AS builder

RUN git clone https://github.com/confluentinc/kafka.git \
    && cd kafka \
    && git checkout tags/v6.0.0-beta200602181840 \
    && ./gradlewAll install \
    && cd ..

RUN git clone https://github.com/confluentinc/common.git \
    && cd common \
    && git checkout tags/v6.0.0-beta200602181840 \
    && mvn install -U \
    && cd ..

RUN mkdir /kafka-connect-elasticsearch
WORKDIR /kafka-connect-elasticsearch


COPY pom.xml pom.xml
RUN mvn dependency:resolve

COPY . .
RUN mvn -U package -DskipTests

FROM alpine
WORKDIR /kafka-connect-elasticsearch

COPY --from=builder /kafka-connect-elasticsearch/target/components/packages/confluentinc-kafka-connect-elasticsearch-6.0.0-beta200602181840/confluentinc-kafka-connect-elasticsearch-6.0.0-beta200602181840 /kafka-connect-elasticsearch
