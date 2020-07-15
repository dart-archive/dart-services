FROM google/dart:2.8.4

WORKDIR /app
RUN groupadd --system dart && \
  useradd --no-log-init --system --home /home/dart --create-home -g dart dart
RUN chown dart:dart /app

USER dart

COPY --chown=dart:dart tool/dart_run.sh /dart_runtime/
COPY --chown=dart:dart pubspec.* /app/
RUN pub get
COPY --chown=dart:dart . /app
RUN pub get --offline

EXPOSE 8080

# Clear out any arguments the base images might have set and ensure we start
# the Dart app using custom script enabling debug modes.
CMD []

ENTRYPOINT /bin/bash /dart_runtime/dart_run.sh
