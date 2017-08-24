# srs-docker
This repository build docker image for [SRS](https://github.com/ossrs/srs).

You can checkout the docker image of [wushaobo/srs-docker](https://hub.docker.com/r/wushaobo/srs-docker/). The tag used below is **1.0** .

## SRS in image

### Version
The version of SRS inside is [v2.0-r2](http://ossrs.net/srs.release/releases/#srs2.0r2).


### 3rd party libs change

Still go ahead with most of 3rd party libs in the srs source, like Nginx(1.5.7), except

- Using the latest stable version of Ffmpeg rather than playing with the old version(2.1.1) inside srs source.

### Configuration

```
./configure --with-hls --with-nginx --with-transcode --with-ingest --with-stat --with-http-callback --with-http-server --with-http-api --log-trace \
				--without-hds --without-ssl --without-dvr --without-ffmpeg --without-stream-caster --without-librtmp --without-research --without-utest --without-gperf --without-gmc --without-gmp --without-gcp --without-gprof --without-arm-ubuntu12 --without-mips-ubuntu12	\
				--jobs=4 --x86-x64 --log-trace
```

## Samples

### Ordinary samples as in SRS repository
There are many samples explained in SRS repository. I pick one of them to demo how we play it with docker.

#### Live in http flv
In this sample, the SRS accepts RTMP stream and generates http flv stream as the output served by a built-in http server. The doc in SRS repository is [here](https://github.com/ossrs/srs/wiki/v2_EN_SampleHttpFlv). 

I suppose you would setup some other services integrating with srs in a compose file, like `samples/compose.srs-http-flv.yml` as follows. 

```
version: '3'

services:
  srs:
    image: wushaobo/srs-docker:1.0
    command: /opt/srs/objs/srs -c /opt/srs/conf/http.flv.live.conf
    ports:
      - "28080:8080"
      - "21935:1935"

```

Run the command as follows.

```
docker-compose -f samples/compose.srs-http-flv.yml up -d srs
```

Then, your inbound RTMP stream could be pushed to the 1935 port of srs container (or 21935 port of the docker host), and the outbound http flv stream could be pulled from the 8080 port of srs container (or 28080 port of the docker host).

### How to extend it
The SRS source includes many config files as samples, but you usually need to customize one config for your exclusive requirement.

The common idea is to pass your own config file in, but I insist on a graceful way. **Using config file generation from environment variables**, it could help to work better with configuration management.

#### Live in hls with hooks

In this sample, the SRS accepts RTMP stream and generates HLS as the output served by the nginx server. Additionally, the SRS is expected to send callback requests when any inbound stream is published or unpublished. 

##### Config file generator
This image includes a config file generator based on a template engine. The template file is in jinja2 and compiled by python.

The callback address should be configured as hooks when running an SRS container. The template file `config_generator/templates/srs_hls_hooks.conf.j2` has these lines

```
...
http_hooks {
    enabled         on;

    on_publish      {{ SRS_CALLBACK_URL }};
    on_unpublish    {{ SRS_CALLBACK_URL }};
}
...
```

You pass the environment variable `SRS_CALLBACK_URL` in when creating the container, 

```
SRS_CALLBACK_URL=http://example.com/api/callback
```

the config file will be generated with the value before being run with.

```
...
http_hooks {
    enabled         on;

    on_publish      http://example.com/api/callback;
    on_unpublish    http://example.com/api/callback;
}
...
```

##### Create SRS container
I suppose you would setup some other services integrating with srs in a compose file, like `samples/compose.srs-hls-with-hooks.yml` as follows. 

```
version: '3'

services:
  srs:
    image: wushaobo/srs-docker:1.0
    command: /tmp/srs/gen_conf_and_run.sh
    ports:
      - "21935:1935"
      - "20080:80"
    environment:
      - config.env

```

And you will pass in a config.env file including environment variables when creating container,

```
SRS_CALLBACK_URL=http://example.com/api/callback
```

Run the command as follows,

```
docker-compose -f samples/compose.srs-hls-with-hooks.yml up -d srs
```

Then, your inbound RTMP stream could be pushed to the 1935 port of srs container (or 21935 port of the docker host), and the outbound HLS could be pulled from the 80 port of srs container (or 20080 port of the docker host).

And when the RTMP stream is successfully pushing/disconnecting to/from SRS, the callback request to `SRS_CALLBACK_URL` will be sent.
