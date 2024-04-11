class LibcapNg < Formula
  desc "Library for Linux that makes using posix capabilities easy"
  homepage "https://people.redhat.com/sgrubb/libcap-ng"
  url "https://people.redhat.com/sgrubb/libcap-ng/libcap-ng-0.8.5.tar.gz"
  sha256 "3ba5294d1cbdfa98afaacfbc00b6af9ed2b83e8a21817185dfd844cc8c7ac6ff"
  license all_of: ["LGPL-2.1-or-later", "GPL-2.0-or-later"]

  bottle do
    rebuild 2
    sha256 cellar: :any_skip_relocation, x86_64_linux: "2c95eb278def830071146f6a7f5e9cdd9f03caf71646604b5a4013a3750375a3"
  end

  head do
    url "https://github.com/stevegrubb/libcap-ng.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
    depends_on "m4" => :build
  end

  depends_on "python-setuptools" => :build
  depends_on "python@3.12" => [:build, :test]
  depends_on "swig" => :build
  depends_on :linux

  def python3
    "python3.12"
  end

  def install
    system "./autogen.sh" if build.head?
    system "./configure", *std_configure_args,
                          "--disable-silent-rules",
                          "--with-python3"
    system "make", "install", "py3execdir=#{prefix/Language::Python.site_packages(python3)}"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <stdio.h>
      #include <cap-ng.h>

      int main(int argc, char *argv[])
      {
        if(capng_have_permitted_capabilities() > -1)
          printf("ok");
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lcap-ng", "-o", "test"
    assert_equal "ok", `./test`
    system python3, "-c", "import capng"
  end
end
