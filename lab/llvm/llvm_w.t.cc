extern "C" {
  int main_c(int argc, char **);
}

int main(int argc, char **argv)
{
  return main_c(argc, argv);
}

