#
# Dockerfile for WordPress
#
FROM appsvcorg/alpine-php-mysql:0.1 
MAINTAINER Azure App Service Container Images <appsvc-images@microsoft.com>

# ========
# ENV vars
# ========

# wordpress
ENV WORDPRESS_SOURCE "/usr/src/wordpress"
ENV WORDPRESS_HOME "/home/site/wwwroot"

#
ENV DOCKER_BUILD_HOME "/dockerbuild"

# ====================
# Download and Install
# ~. tools
# 1. redis
# 2. wordpress
# ====================

WORKDIR $DOCKER_BUILD_HOME
RUN set -ex \
	# --------
	# 1. redis
	# --------
        && apk add --update redis \
	# ------------	
	# 2. wordpress
	# ------------
	&& mkdir -p $WORDPRESS_SOURCE \
        # cp in final
	# ----------
	# ~. clean up
	# ----------
	&& rm -rf /var/cache/apk/* 

# =========
# Configure
# =========
# httpd confs
COPY httpd-wordpress.conf $HTTPD_CONF_DIR/

RUN set -ex \
	##
	&& ln -s $WORDPRESS_HOME /var/www/wordpress \
    ##
    && test -e /usr/local/bin/entrypoint.sh && mv /usr/local/bin/entrypoint.sh /usr/local/bin/entrypoint.bak

# =====
# Install memcached
# =====

RUN { \
		echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=60'; \
        echo 'opcache.fast_shutdown=1'; \
        echo 'opcache.enable_file_override=1'; \
    } > /usr/local/php/etc/conf.d/php-opcache-custom.ini

# =====
# final
# =====
COPY wp.tar.gz $WORDPRESS_SOURCE/
COPY wp-config.php $WORDPRESS_SOURCE/

COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
EXPOSE 2222 80
ENTRYPOINT ["entrypoint.sh"]
