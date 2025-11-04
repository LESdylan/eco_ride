The single Sass file that ties it all together. We'll compile this one only

> To compile everything from main.scss into ../../css/style.css

```bash
sass main.scss ../../css/style.css --style=compressed --load-path=.
```

Or use the Makefile:

```bash
make         # build
make minify  # build compressed
make watch   # watch and rebuild
make check   # verify outputs exist
```
