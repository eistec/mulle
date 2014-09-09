# Test suites are not supported, because they try to link w/o startup code
require 'formula'

class ArmNoneEabiGcc < Formula
  url 'http://ftpmirror.gnu.org/gcc/gcc-4.8.2/gcc-4.8.2.tar.bz2'
  mirror 'http://ftp.gnu.org/gnu/gcc/gcc-4.8.2/gcc-4.8.2.tar.bz2'
  homepage 'http://www.gnu.org/software/gcc/gcc.html'
  sha1 '810fb70bd721e1d9f446b6503afe0a9088b62986'

  resource "newlib" do
    url 'ftp://sourceware.org/pub/newlib/newlib-2.0.0.tar.gz'
    sha1 'ea6b5727162453284791869e905f39fb8fab8d3f'
  end

  depends_on 'gmp'
  depends_on 'mpfr'
  depends_on 'libmpc'
  depends_on 'ppl10'
  depends_on 'cloog'

  depends_on 'arm-none-eabi-binutils'

  option 'disable-cxx', 'Don\'t build the g++ compiler'

  def install
    # Build fails with clang
    #ENV.llvm
    #ENV.gcc

    resource("newlib").stage do
        (buildpath).install Dir['newlib', 'libgloss']
    end

    target = "arm-none-eabi"

    languages = %w[c]
    languages << 'c++' unless build.include? 'disable-cxx'

    args = ["--target=#{target}",
            "--prefix=#{prefix}",
            "--enable-multilib",
            "--with-newlib",
            "--with-gnu-as",
            "--with-gnu-ld",
            "--disable-nls",
            "--disable-shared",
            "--disable-threads",
            "--with-headers=newlib/libc/include",
            "--disable-libssp",
            "--disable-libstdcxx-pch",
            "--disable-libmudflap",
            "--disable-libgomp",
            "--disable-werror",
            "--disable-newlib-supplied-syscalls"]

    args << "--enable-languages=#{languages.join(',')}"

    ['gmp', 'mpfr', 'ppl10', 'cloog'].each do |dep|
      args << "--with-#{dep}=#{(Formula.factory dep).prefix}"
    end

    args << "--with-mpc=#{(Formula.factory 'libmpc').prefix}"

    args << "--with-as=#{(Formula.factory 'arm-none-eabi-binutils').prefix}/bin/arm-none-eabi-as"
    args << "--with-ld=#{(Formula.factory 'arm-none-eabi-binutils').prefix}/bin/arm-none-eabi-ld"

    # This is a temporary fix. GCC requires this to build with PPL 1.0 instead of PPL 0.11
    # Taken from https://trac.macports.org/changeset/94941
    args << "--disable-ppl-version-check"
    # Same for Cloog
    args << "--disable-cloog-version-check"


    args << "--enable-cloog-backend=isl"


    mkdir 'build' do
      #interactive_shell

      system "../configure", *args

      #interactive_shell

      system "make"
      system "make install"

      # Do not install libiberty.a, as it may conflict with host file
      multios = `gcc --print-multi-os-directory`.chomp
      File.unlink "#{lib}/#{multios}/libiberty.a"
    end
  end
end
