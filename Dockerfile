FROM openjdk:11
RUN apt update && apt upgrade -y && apt install -y vim less file
COPY src /skyfire/src
COPY lib /skyfire/lib
COPY res /skyfire/res
COPY entrypoint.sh /skyfire/entrypoint.sh
WORKDIR /skyfire/
RUN  javac -cp "/skyfire/src/antlr/antlr-4.7-complete.jar:/skyfire/lib/mysql-connector-java-5.1.46-bin.jar:/skyfire/src/:." /skyfire/src/learning/XMLPCSGLearner.java
RUN  javac -cp "/skyfire/src/antlr/antlr-4.7-complete.jar:/skyfire/lib/mysql-connector-java-5.1.46-bin.jar:/skyfire/src/:." /skyfire/src/generation/XMLGenerator.java
CMD ["./entrypoint.sh"]