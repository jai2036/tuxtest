/*	(c) 2003 BEA Systems, Inc. All Rights Reserved. */
/*	Copyright (c) 1997 BEA Systems, Inc.
  	All rights reserved

  	THIS IS UNPUBLISHED PROPRIETARY
  	SOURCE CODE OF BEA Systems, Inc.
  	The copyright notice above does not
  	evidence any actual or intended
  	publication of such source code.
*/

/* #ident	"@(#) samples/atmi/simpapp/simpcl.c	$Revision: 1.5 $" */
#include <string.h>   /*Include string.h */
#include <stdio.h>
#include "atmi.h"		/* TUXEDO  Header File */
#include <userlog.h>	/* TUXEDO Header File */
#include "appdynamics.h" /*APPD specifics*/

/*------AppD Specifics-----*/
#define TIME_OUT 60000  
int init_sdk(); 
int initialised=0;
const char* backendname= "TOUPPER";
const char* key = "service";
const char* value = "UPPER";
/*---------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
main(int argc, char *argv[])
#else
main(argc, argv)
int argc;
char *argv[];
#endif

{
	/*Appd initializations */
	if (!initialised) {
		userlog("APPD:1st call - not initialised yet");
		initialised=init_sdk();
		userlog("APPD:Initialisation complete: %d", initialised);
	}

	appd_backend_declare("tpcall", backendname); 
	appd_backend_set_identifying_property(backendname,key,value);
	appd_backend_add(backendname);

	/*Appd ends*/
	char *sendbuf, *rcvbuf;
	long sendlen, rcvlen;
	int ret;

	if(argc != 3) {
		(void) fprintf(stderr, "Usage: simpcl string\n");
		exit(1);
	}

	/* Attach to System/T as a Client Process */
	if (tpinit((TPINIT *) NULL) == -1) {
		(void) fprintf(stderr, "Tpinit failed\n");
		exit(1);
	}
	
	sendlen = strlen(argv[1]);

	/* Allocate STRING buffers for the request and the reply */

	if((sendbuf = (char *) tpalloc("STRING", NULL, sendlen+1)) == NULL) {
		(void) fprintf(stderr,"Error allocating send buffer\n");
		tpterm();
		exit(1);
	}


	(void) strcpy(sendbuf, argv[1]);
	
	int MAX_LOOP = atoi(argv[2]);
	int itr = 0;
	
	while (itr < MAX_LOOP)
	{
		itr++; 
		if((rcvbuf = (char *) tpalloc("STRING", NULL, sendlen+1)) == NULL) {
			(void) fprintf(stderr,"Error allocating receive buffer\n");
			tpfree(sendbuf);
			tpterm();
			exit(1);
		}
		appd_bt_handle btHandle = appd_bt_begin("tuxclient-tpcall", NULL);  
		appd_exitcall_handle ecHandle = appd_exitcall_begin(btHandle, backendname);
		/* Request the service TOUPPER, waiting for a reply */
		ret = tpcall("TOUPPER", (char *)sendbuf, 0, (char **)&rcvbuf, &rcvlen, (long)0);

		if(ret == -1) {
			(void) fprintf(stderr, "Can't send request to service TOUPPER\n");
			(void) fprintf(stderr, "Tperrno = %d\n", tperrno);
			tpfree(sendbuf);
			tpfree(rcvbuf);
			tpterm();
			appd_exitcall_end(ecHandle);
			appd_bt_end(btHandle);
			appd_sdk_term();
			exit(1);
		}
		else {
			(void) fprintf(stdout, "Returned string is: %s, tpcall count: %d \n", rcvbuf, itr);
			sleep(1.5); // this is an intentional delay to validate metrics  
			appd_exitcall_end(ecHandle);
			appd_bt_end(btHandle);
			tpfree(rcvbuf);
		}
	}
	/* Free Buffers & Detach from System/T */
	tpfree(sendbuf);
	tpterm();
	appd_sdk_term();
	(void) fprintf(stdout, "Gracefully stopped! \n");
	return(0);

}

int init_sdk()
{
	userlog("APPD: Inside init_sdk()");
	const char APP_NAME[] = "CppTuxSimpApp";
	const char TIER_NAME[] = "CPPtier1";
	const char NODE_NAME[] = "CPPNode1";
	const char CONTROLLER_HOST[] = "";
	const int CONTROLLER_PORT = 80;
	const char CONTROLLER_ACCOUNT[] = "";
	const char CONTROLLER_ACCESS_KEY[] = "";
	const int CONTROLLER_USE_SSL = 0;
	// Appd Agent initialisation <starts>
	struct appd_config *cfg = appd_config_init();
	appd_config_set_app_name(cfg, APP_NAME);
	appd_config_set_tier_name(cfg, TIER_NAME);
	appd_config_set_node_name(cfg, NODE_NAME);
	appd_config_set_controller_host(cfg, CONTROLLER_HOST);
	appd_config_set_controller_port(cfg, CONTROLLER_PORT);
	appd_config_set_controller_account(cfg, CONTROLLER_ACCOUNT);
	appd_config_set_controller_access_key(cfg, CONTROLLER_ACCESS_KEY);
	appd_config_set_controller_use_ssl(cfg, CONTROLLER_USE_SSL); 
	//appd_config_set_controller_http_proxy_host(cfg, CONTROLLER_HTTP_PROXY_HOST);
	//appd_config_set_controller_http_proxy_port(cfg, CONTROLLER_HTTP_PROXY_PORT);
	appd_config_set_logging_min_level(cfg, APPD_LOG_LEVEL_INFO);
	appd_config_set_flush_metrics_on_shutdown(cfg, 1); // 1 to capture matrics & 0 to ignore
	appd_config_set_init_timeout_ms(cfg,TIME_OUT);
	int initRC; 
	initRC = appd_sdk_init(cfg); 
	if (!initRC) {
		userlog("APPD:Initialisation successful! %d", initRC);
	}
	else 
	{
		userlog("APPD:Initialization failed!, %d", initRC);
		return initRC;
	}
 return initRC; //true 

}
