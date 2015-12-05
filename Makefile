.PHONY: clean clean-build clean-pyc clean-test clean-docs lint test test-all coverage coverage docs servedocs release dist install register requirements
define BROWSER_PYSCRIPT
import os, webbrowser, sys
try:
	from urllib import pathname2url
except:
	from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT
BROWSER := python -c "$$BROWSER_PYSCRIPT"

help:
	@echo "clean			remove all build, test, coverage and Python artifacts"
	@echo "clean-build		remove build artifacts"
	@echo "clean-pyc		remove Python file artifacts"
	@echo "clean-test		remove test and coverage artifacts"
	@echo "clean-docs		remove autogenerated docs files"
	@echo "lint				check style with flake8"
	@echo "test				run tests quickly with the default Python"
	@echo "test-all			run tests on every Python version with tox"
	@echo "coverage			check code coverage quickly with the default Python"
	@echo "docs				generate Sphinx HTML documentation, including API docs"
	@echo "servedocs		semi-live edit docs"
	@echo "release			package and upload a release"
	@echo "dist				package"
	@echo "install			install the package to the active Python's site-packages"
	@echo "register			update pypi"
	@echo "requirements		update and install requirements"

clean: clean-build clean-pyc clean-test clean-docs

clean-build:
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -f {} +

clean-pyc:
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

clean-test:
	rm -fr .tox/
	rm -f .coverage
	rm -fr htmlcov/

clean-docs:
	rm -f docs/source/lanyrd.rst
	rm -f docs/source/modules.rst
	$(MAKE) -C docs clean

lint:
	flake8 lanyrd tests

test: lint
	python setup.py test

test-all: lint
	tox

coverage:
	coverage run --source lanyrd setup.py test
	coverage report -m
	coverage html
	$(BROWSER) htmlcov/index.html
	$(MAKE) -C docs coverage

docs: clean-docs
	sphinx-apidoc -o docs/source/ lanyrd
	$(MAKE) -C docs html
	$(BROWSER) docs/build/html/index.html

servedocs: docs
	watchmedo shell-command -p '*.rst' -c '$(MAKE) -C docs html' -R -D .

release: clean docs
	python setup.py sdist upload
	python setup.py bdist_wheel upload

dist: clean docs
	python setup.py sdist
	python setup.py bdist_wheel
	ls -l dist

install: clean
	python setup.py install

register:
	python setup.py register

requirements:
	pip install --quiet pip-tools
	pip-compile requirements_dev.in > /dev/null
	pip-sync requirements_dev.txt > /dev/null
	python setup.py install --quiet > /dev/null
	pip wheel --quiet -r requirements_dev.txt
