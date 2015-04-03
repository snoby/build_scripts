#/bin/bash +x
set -x

V=1.4.4
ROOT=$PWD
PREFIX="/opt/"
PKG_CONFIG=${PREFIX}/lib/pkgconfig


mkdir -p  downloads build src

#
# xvimagesink supports yuv format, while ximagesink only rgb,
# it's useful for play video, since you can skip the ffmpegcolorspace's
# yuv2rgb convert and save cpu time.
#
# note you have to change the pkconfig file for libsoup because it still shows 2.38.1 instead of 2.40.1
#
preinstall()
{
   sudo apt-get install -y libxv-dev \
                           libogg-dev \
                           libsoup2.4-dev \
                           liba52-dev \
                           yasm       \
                           doxygen       \
                           libmpeg2-4-dev \
                           libmad0-dev \
                           libvorbis-dev

}
download_src ()
{
   mkdir -p ${ROOT}/downloads
   pushd ${ROOT}/downloads

   if [ ! -e gstreamer-{V}.tar.xz ]; then
   curl -OL http://gstreamer.freedesktop.org/src/gstreamer/gstreamer-${V}.tar.xz
   fi

   if [ ! -e gst-plugins-base-{V}.tar.xz ]; then
   curl -OL http://gstreamer.freedesktop.org/src/gst-plugins-base/gst-plugins-base-${V}.tar.xz
   fi

   if [ ! -e gst-plugins-good-{V}.tar.xz ]; then
   curl -OL http://gstreamer.freedesktop.org/src/gst-plugins-good/gst-plugins-good-${V}.tar.xz
   fi

   if [ ! -e gst-plugins-bad-{V}.tar.xz ]; then
   curl -OL http://gstreamer.freedesktop.org/src/gst-plugins-bad/gst-plugins-bad-${V}.tar.xz
   fi

   if [ ! -e gst-plugins-ugly-{V}.tar.xz ]; then
   curl -OL http://gstreamer.freedesktop.org/src/gst-plugins-ugly/gst-plugins-ugly-${V}.tar.xz
   fi

   if [ ! -e gst-libav-{V}.tar.xz ]; then
   curl -OL http://gstreamer.freedesktop.org/src/gst-libav/gst-libav-${V}.tar.xz
   fi

   # might need uriparser also
   if [ ! -e uriparser-0.8.1.tar.bz2 ]; then
   curl -L http://sourceforge.net/projects/uriparser/files/latest/download?source=directory > uriparser-0.8.1.tar.bz2
   fi

   popd


}
#
# for the dlnasrc plugin need newest version of uriparse
#
untar_src()
{
   pushd ${ROOT}/src
   tar xf ${ROOT}/downloads/gstreamer-${V}.tar.xz
   tar xf ${ROOT}/downloads/gst-plugins-base-${V}.tar.xz
   tar xf ${ROOT}/downloads/gst-plugins-good-${V}.tar.xz
   tar xf ${ROOT}/downloads/gst-plugins-bad-${V}.tar.xz
   tar xf ${ROOT}/downloads/gst-plugins-ugly-${V}.tar.xz
   tar xf ${ROOT}/downloads/gst-libav-${V}.tar.xz
   tar jxf ${ROOT}/downloads/uriparser-0.8.1.tar.bz2
   popd
}

build_gstreamer()
{
   pushd ${ROOT}/build
   mkdir gstreamer
   cd gstreamer
   ${ROOT}/src/gstreamer-${V}/configure --prefix=${PREFIX}
   make -j
   make install
   popd
}



build_base()
{
   pushd ${ROOT}/build
   mkdir base
   cd base
   PKG_CONFIG_PATH=${PKG_CONFIG} ${ROOT}/src/gst-plugins-base-${V}/configure --prefix=${PREFIX}
   make -j
   make install
   popd
}



build_good()
{
   pushd ${ROOT}/build
   mkdir good
   cd good
   PKG_CONFIG_PATH=${PKG_CONFIG} ${ROOT}/src/gst-plugins-good-${V}/configure --prefix=${PREFIX}
   make -j
   make install
   popd
}

build_bad()
{
   pushd ${ROOT}/build
   mkdir bad
   cd bad
   PKG_CONFIG_PATH=${PKG_CONFIG} ${ROOT}/src/gst-plugins-bad-${V}/configure --prefix=${PREFIX}
   make -j
   make install
   popd
}


build_libav()
{
   pushd ${ROOT}/build
   mkdir libav
   cd libav
   PKG_CONFIG_PATH=${PKG_CONFIG} ${ROOT}/src/gst-libav-${V}/configure --prefix=${PREFIX}
   make -j
   make install
   popd
}
build_ugly()
{
   pushd ${ROOT}/build
   mkdir ugly
   cd ugly
   PKG_CONFIG_PATH=${PKG_CONFIG} ${ROOT}/src/gst-plugins-ugly-${V}/configure --prefix=${PREFIX}
   make -j
   make install
   popd
}

build_uriparser()
{
   pushd ${ROOT}/build
   mkdir parser
   cd parser
   PKG_CONFIG_PATH=${PKG_CONFIG} ${ROOT}/src/uriparser-0.8.1/configure --prefix=${PREFIX} --disable-test --disable-doc
   make -j
   make install
   popd
}


#
#
#
echo "You can also source the script to build things individually if you like..."
echo "REMEMBER you must manually change the package config file for libsoup2.4-dev because it shows the wrong version"
echo "also remember you have to own the /opt directory to install without sudo "
sleep 2

preinstall
download_src
untar_src
build_gstreamer
build_base
build_good
build_bad
build_libav
build_ugly
build_uriparser
#


