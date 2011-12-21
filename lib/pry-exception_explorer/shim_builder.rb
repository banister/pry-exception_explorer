require 'rbconfig'
require 'fileutils'

module PryExceptionExplorer
  module ShimBuilder
    class << self
      attr_reader :dir, :file
    end

    @dir = File.expand_path('~/.pry-exception_explorer')
    @file = File.join(@dir, "raise_shim.c")

    if RUBY_PLATFORM =~ /darwin/
      Dyname = "dylib"
    else
      Dyname = "so"
    end

    ShimCode = <<-EOF
#include <stdio.h>
#include <dlfcn.h>
#include <stdlib.h>
#include <unistd.h>
#include <ruby.h>

void
rb_exc_raise(VALUE mesg)
{
  static void (*libruby_rb_exc_raise)
    (VALUE mesg) = NULL;

  void * handle;
  char * error;

  if (!libruby_rb_exc_raise) {
    handle = dlopen("#{RbConfig::CONFIG['libdir']}/libruby.#{Dyname}", RTLD_LAZY);
    if (!handle) {
      fputs(dlerror(), stderr);
      exit(1);
    }
    libruby_rb_exc_raise = dlsym(handle, "rb_exc_raise");
    if ((error = dlerror()) != NULL) {
      fprintf(stderr, "%s", error);
      exit(1);
    }
  }

  // VALUE caller_bindings = rb_funcall(rb_binding_new(), rb_intern("callers"), 0);
  // rb_funcall(mesg, rb_intern("exception_call_stack="), 1, caller_bindings);
  VALUE caller_bindings = rb_ary_new3(1, rb_eval_string("binding"));
 // rb_funcall(mesg, rb_intern("exception_call_stack="), 1, caller_bindings);
  //rb_funcall(mesg, rb_intern("display"), 0);
 // rb_iv_set(mesg, "@exception_call_stack", caller_bindings);
  rb_p(rb_str_new2("yo yo"));
  libruby_rb_exc_raise(mesg);
}
EOF

    def self.create_directory_and_source_file
      FileUtils.mkdir_p(@dir)
      File.open(@file, 'w') do |f|
        f.puts(ShimCode)
      end
    end

    def self.compile
      create_directory_and_source_file

      # -L
      lib_dir = RbConfig::CONFIG['libdir']

      # -I
      arch_include = File.join RbConfig::CONFIG['includedir'], "ruby-1.9.1",  RbConfig::CONFIG['arch']
      backward_include = File.join RbConfig::CONFIG['includedir'], "ruby-1.9.1",  "ruby/backward"
      ruby191_include = File.join RbConfig::CONFIG['includedir'], "ruby-1.9.1"

      if RUBY_PLATFORM =~ /darwin/
        compile_line = "gcc -Wall -L#{lib_dir} -lruby -I#{arch_include}  -I#{backward_include} -I#{ruby191_include} -o lib_overrides.dylib -dynamiclib #{@file}"
      else
        compile_line = "gcc -Wall -O2 -fpic -shared -ldl -g -I#{arch_include}  -I#{backward_include} -I#{ruby191_include} -o lib_overrides.so #{@file}"
      end

      FileUtils.chdir @dir do
        system(compile_line)
      end

    end
  end
end
