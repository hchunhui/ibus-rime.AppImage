#include <unistd.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
	if (argc == 1)
		return 127;

	char *p = argv[1];
	char *argv0 = getenv("ARGV0");

	if (argv0)
		argv[1] = argv0;

	return execvp(p, argv + 1);
}
