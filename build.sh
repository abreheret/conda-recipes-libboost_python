set -x -e

INCLUDE_PATH="${PREFIX}/include"
LIBRARY_PATH="${PREFIX}/lib"

if [ "$(uname)" == "Darwin" ]; then
    MACOSX_VERSION_MIN=10.6
    CXXFLAGS="-mmacosx-version-min=${MACOSX_VERSION_MIN}"
    CXXFLAGS="${CXXFLAGS} -stdlib=libstdc++"
    LINKFLAGS="-mmacosx-version-min=${MACOSX_VERSION_MIN}"
    LINKFLAGS="${LINKFLAGS} -stdlib=libstdc++ -L${LIBRARY_PATH}"

    ./bootstrap.sh \
        --prefix="${PREFIX}" \
        --with-python="${PYTHON}" \
        --with-python-root="${PREFIX} : ${PREFIX}/include/python${PY_VER}m ${PREFIX}/include/python${PY_VER}" \
        --with-icu="${PREFIX}" \
        | tee bootstrap.log 2>&1

    ./b2 -q \
        variant=release \
        address-model=64 \
        architecture=x86 \
        debug-symbols=off \
        threading=multi \
        link=static,shared \
        toolset=clang \
        include="${INCLUDE_PATH}" \
        cxxflags="${CXXFLAGS}" \
        linkflags="${LINKFLAGS}" \
        -j"$(sysctl -n hw.ncpu)" \
        install | tee b2.log 2>&1
fi

if [ "$(uname)" == "Linux" ]; then
    ./bootstrap.sh \
        --prefix="${PREFIX}" \
        --with-python="${PYTHON}" \
        --with-python-root="${PREFIX} : ${PREFIX}/include/python${PY_VER}m ${PREFIX}/include/python${PY_VER}" \
        --with-icu="${PREFIX}" \
        | tee bootstrap.log 2>&1

    ./b2 -q \
        variant=release \
        address-model="${ARCH}" \
        architecture=x86 \
        debug-symbols=off \
        threading=multi \
        runtime-link=shared \
        link=static,shared \
        toolset=gcc \
        python="${PY_VER}" \
        include="${INCLUDE_PATH}" \
        linkflags="-L${LIBRARY_PATH}" \
        --layout=system \
        -j"${CPU_COUNT}" \
        install | tee b2.log 2>&1
fi
