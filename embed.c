#include "ruby.h"
#include <stdio.h>

int add_ref(void* base)
{
  printf("[C] Adding a reference");
  return 1;
}

int release(void* base)
{
  printf("[C] Releasing a reference");
  return 1;
}

int get_refct(void* base)
{
  printf("[C] Returning reference count");
  return 1;
}

int main(int argc, char *argv[])
{
  int i;
  for(i=0; i <= argc - 1; ++i)
  {
    printf("%s", argv[i]);
  }
	ruby_sysinit(&argc, &argv);
	{
  	RUBY_INIT_STACK;
  	ruby_init();
  	ruby_init_loadpath();
    VALUE array = rb_ary_new2(argc);
    for(i=0; i <= argc - 1; ++i)
    {
      rb_ary_push(array, rb_str_new2(argv[i]));
    }

    rb_funcall(Qnil, rb_intern("require"), 1, rb_str_new2("./libcef-test.rb"));
    rb_funcall(Qnil, rb_intern("run"), 1, array);
	}
	return 0;
}
