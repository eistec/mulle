require 'formula'

class ArmNoneEabiGdb < Formula
  url 'http://ftp.gnu.org/gnu/gdb/gdb-7.8.tar.gz'
  #mirror 'http://ftp.gnu.org/gun/binutils/binutils-2.23.1.tar.bz2'
  homepage 'http://www.gnu.org/software/binutils/binutils.html'
  sha1 '4810d78a77064fefc05e701fc0a2193562a23afe'

  option 'skip-tests', 'Don\'t run the testsuite'

  depends_on 'arm-none-eabi-gcc'

  def install
    target = "arm-none-eabi"

    args = ["--target=#{target}",
            "--prefix=#{prefix}"]

    mkdir 'build' do
        system "../configure", *args

        system "make"
        #system "make check" unless build.include? 'skip_tests'
        system "make install"
    end
  end
end
