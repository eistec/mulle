require 'formula'

class ArmNoneEabiBinutils < Formula
  url 'http://ftpmirror.gnu.org/binutils/binutils-2.23.1.tar.bz2'
  mirror 'http://ftp.gnu.org/gun/binutils/binutils-2.23.1.tar.bz2'
  homepage 'http://www.gnu.org/software/binutils/binutils.html'
  sha1 '587fca86f6c85949576f4536a90a3c76ffc1a3e1'

  option 'skip-tests', 'Don\'t run the testsuite'


  def install
    target = "arm-none-eabi"

    args = ["--target=#{target}",
            "--prefix=#{prefix}",
            "--enable-multilib",
            "--with-gnu-as",
            "--with-gnu-ld",
            "--disable-werror",
            "--disable-nls"]

    mkdir 'build' do
        system "../configure", *args

        system "make"
        system "make check" unless build.include? 'skip_tests'
        system "make install"


        # Do not install libiberty.a, as it may conflict with host file
        multios = `gcc --print-multi-os-directory`.chomp
        File.unlink "#{lib}/#{multios}/libiberty.a"
    end
  end
end
