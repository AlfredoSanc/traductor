#!/usr/bin/python
import click
import yaml
import pycurl
import certifi
import os
from colorama import Fore, Back, Style

@click.group()
def cli():
    pass

@cli.command()
@click.argument('yaml_file', type=click.File('r'))
def available(yaml_file):
    with yaml_file as stream:
        data = yaml.safe_load(stream)
    print("Project name",data['name'])
    for info in data['targets']:
        print(f"{Fore.RED}Target:{Fore.RESET} {info['target']}")
        print(f"{Fore.RED}Files:{Fore.RESET}")
        for file in info['files']:
            print(f" Type :{Fore.YELLOW} {file['type']}{Fore.RESET}")
            print(f" Link :{Fore.YELLOW} {file['link']}{Fore.RESET}")

@cli.command()
@click.argument('yaml_file', type=click.File('r'))
@click.option('target','--target', '-t', multiple=True, default=[])
@click.option('directory', '--dir', type=click.Path(),default="data")
@click.option('--test', is_flag=True)
def download(yaml_file,target,test,directory):
    with yaml_file as stream:
        data = yaml.safe_load(stream)

    for info in data['targets']:
        if len(target)>0 and not info['target'] in target:
            continue
        print(f"{Fore.YELLOW}{info['target']}{Fore.RESET}")
        for file in info['files']:
                filename=os.path.join(directory,f"{info['target']}.{data['name']}.{file['type']}")
                if not test:
                    print(f"{Fore.GREEN}Downloading:{Fore.RESET} {file['link']} to {filename}" )
                    with open(filename, 'wb') as f:
                        c = pycurl.Curl()
                        c.setopt(c.URL, file['link'])
                        c.setopt(c.FOLLOWLOCATION, True)
                        c.setopt(c.WRITEDATA, f)
                        c.setopt(c.CAINFO, certifi.where())
                        c.perform()
                        c.close()
                    print(f"{Fore.GREEN}Saved into file:{Fore.RESET} {file['link']}")
                else:
                    print(f"{Fore.RED} Would download:{Fore.RESET} {file['link']} {Fore.RED}to{Fore.RESET} {filename}")



if __name__ == '__main__':
    cli()
