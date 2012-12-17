#!/usr/bin/python

import BaseHTTPServer
import SimpleHTTPServer
import os
import subprocess
import shlex
import sys
import multiprocessing
import socket

# You can use: 'python -m SimpleHTTPServer 8000' but that won't advertise the server via Bonjour
# This version picks a random port and advertise the server.

def main(path = '.', address = 'localhost', name = None, type = '_http._tcp', domain = '.', ipv6 = False, open = False, advertise = True, port = 0, TXTRecord = None):

	protocol="HTTP/1.0"

	print address
	if address == '0.0.0.0' and ipv6:
		address = '::'

	os.chdir(path)

	# Set up handler c;ass...
	HandlerClass = SimpleHTTPServer.SimpleHTTPRequestHandler
	HandlerClass.protocol_version = protocol

	# Set up server class...
	ServerClass = BaseHTTPServer.HTTPServer
	if ipv6:
		ServerClass.address_family = socket.AF_INET6

	# Create server...
	server_address = (address, port)
	server = ServerClass(server_address, HandlerClass)
	address, port = server.socket.getsockname()[0:2]

	thePipe = None

	url = 'http://localhost:%s/' % (port)

	def serve():
		try:
			server.serve_forever()
		except:
			pass

	#### Start the server in new process...
	print "#### Serving HTTP on %s" % url
	theProcess = multiprocessing.Process(target = serve)
	theProcess.start()

	try:
		#### Advertise the server using long living dns-sd...
		if advertise:
			assert name
			assert type
			assert domain
			assert port
			print '#### Advertising service.'
			theArguments = 'dns-sd -R \'%s\' \'%s\' \'%s\' %s' % (name, type, domain, port)
			if TXTRecord:
				theArguments += ' ' + ' '.join([k +  '=' + v for k, v in TXTRecord.items()])
			print theArguments
			theArguments = shlex.split(theArguments)
#			thePipe = subprocess.Popen(theArguments)
			thePipe = subprocess.Popen(theArguments, stdout = subprocess.PIPE)

		#### Open a web browser to the server...
		if open:
			assert url
			theArguments = 'open \'%s\'' % url
			theArguments = shlex.split(theArguments)
			subprocess.call(theArguments)

		theProcess.join()
	except:
		pass
	finally:
		if thePipe:
			print '#### Stopping advertising.'
			thePipe.terminate()

	if 'name' not in args:
		args['name'] = os.path.split(os.path.abspath(os.path.join(os.getcwd(), args['path'])))[1]
	return(args)

if __name__ == '__main__':


	path = sys.argv[1]
	name = sys.argv[2]
	TXTRecord = { sys.argv[3]: sys.argv[4] }

	main(path = path, name = name, TXTRecord = TXTRecord)

