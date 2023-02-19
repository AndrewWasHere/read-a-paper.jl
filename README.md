# Read a Paper

Choose a random paper (that hasn't been chosen recently) from the Papers We Love
repo on Github and suggest it somewhere, be it on the command line (useful for
debugging), or Discord (or any other site with a simple webhook).

Inspired by the [love-a-paper](https://github.com/imwally/love-a-paper) bot that
used to post to Twitter.

The assumed use case is this project is run on an always-on Linux device 
(e.g. Raspberry Pi) with Internet access on a periodic basis (e.g. via cron).

## Use

Clone the Love a Paper repo somewhere. The default location is below this
directory.

```shell
# With Github CLI:
$ gh clone love-a-paper/love-a-paper

# With Git:
$ git clone https://github.com/papers-we-love/papers-we-love.git
```

Run the `suggest_a_paper.jl` script from the command line to see it in action.

```shell
$ julia --project=. suggest_a_paper.jl
```

Or run it from a cron job via the helper script. While you're there, set up a 
cron job to pull the Papers we Love repo to keep it up to date. The example 
shows updates happening on the 13th of the monthly at 01:00, and paper 
suggestions daily at 18:30.

```shell
# Launch crontab editor for user account:
$ crontab -e

# Add to crontab file:
*  1  13 *  * /path/to/project/update_papers
30 18 *  *  * /path/to/project/suggest_a_paper
```

See https://crontab.guru for help setting up crontab.

## Dependencies

* Julia 1.8+
* HTTP.jl
* git

## License

MIT License. See LICENSE.txt.

