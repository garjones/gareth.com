# gareth.com scripts

Repository of scripts that automate various different server configurations. Most of these configurations are fully documented on my blog (http://www.gareth.com) in an article that is referenced in the comments at the top of the script. As most of these configuration scripts are a single file, I (currently) do not normally organize them into folders. 

I typically run these scripts directly from github using the following kind of command ...
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/garjones/gareth.com/master/xxx.sh)"
```

The above command downloads the script and pipes the output directly to the shell. This is not recommended without reading and fully understanding the contents of the script and is normally thought of as a security convern - so beware.
