/*
 *  iOS Ports Library
 *  Copyright (c) 2010, Bindle Binaries
 *  All rights reserved.
 *
 *  @BINDLE_BINARIES_BSD_LICENSE_START@
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are
 *  met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of Bindle Binaries nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 *  IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 *  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 *  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL BINDLE BINARIES BE LIABLE FOR
 *  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 *  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 *  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 *  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 *  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 *  OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 *  SUCH DAMAGE.
 *
 *  @BINDLE_BINARIES_BSD_LICENSE_END@
 */
/**
 *  @file ports/iOSPorts/classes/iOSPortsPackage.m interface to PKGDATA
 */

#import "iOSPortsPackage.h"
#import <stdio.h>
#import <dlfcn.h>
#import <string.h>


@implementation iOSPortsPackage

@synthesize identifier;
@synthesize name;
@synthesize version;
@synthesize website;
@synthesize license;


- (void)dealloc
{
   self.identifier = nil;
   self.name = nil;
   self.version = nil;
   self.website = nil;
   self.license = nil;

   if (identifierUTF8)
      free(identifierUTF8);
   identifierUTF8 = NULL;

   [super dealloc];

   return;
}


- (iOSPortsPackage *) initWithIdentifier:(NSString *)anIdentifier
{
   if (!(self = [super init]))
      return(self);

   if ([self lookupIdentifier:anIdentifier])
   {
      [self release];
      self = nil;
   };

   return(self);
}


+ (iOSPortsPackage *) iOSPortsPackageWithIdentifier:(NSString *)anIdentifier
{
   iOSPortsPackage * portpkg;
   portpkg = [[iOSPortsPackage alloc] initWithIdentifier:anIdentifier];
   return([portpkg autorelease]);
}


- (BOOL) lookupIdentifier:(NSString *)anIdentifier
{
   char                    symbolName[512];
   unsigned                u;
   const char            * str;
   NSAutoreleasePool     * pool;
   const iOSPortsPKGData * datap;

   pool = [[NSAutoreleasePool alloc] init];

   self.identifier = nil;
   self.name       = nil;
   self.version    = nil;
   self.website    = nil;
   self.license    = nil;

   str = [anIdentifier UTF8String];
   if (identifierUTF8)
      free(identifierUTF8);
   if (!(identifierUTF8 = strdup(str)))
   {
      [pool release];
      return(YES);
   };

   for(u = 0; u < strlen(identifierUTF8); u++)
   {
      if ((identifierUTF8[u] >= 'A') && (identifierUTF8[u] <= 'Z'))
         identifierUTF8[u] = identifierUTF8[u] - 'A' +'a';
      else if ( ((identifierUTF8[u] < 'a') || (identifierUTF8[u] > 'z')) &&
                ((identifierUTF8[u] < '0') || (identifierUTF8[u] > '9')) )
         identifierUTF8[u] = '_';
   };

   snprintf(symbolName, 512, "iOSPorts_pkgdata_%s", identifierUTF8);

   if (!(datap = (const iOSPortsPKGData *) dlsym(RTLD_SELF, symbolName)))
   {
      NSLog(@"%s: dlsym(%s): %s\n", identifierUTF8, symbolName, dlerror());
      [pool release];
      return(YES);
   };

   self.identifier = datap->pkg_id         ? [NSString stringWithUTF8String:datap->pkg_id]      : nil;
   self.name       = datap->pkg_name       ? [NSString stringWithUTF8String:datap->pkg_name]    : nil;
   self.version    = datap->pkg_version    ? [NSString stringWithUTF8String:datap->pkg_version] : nil;
   self.website    = datap->pkg_website    ? [NSString stringWithUTF8String:datap->pkg_website] : nil;
   self.license    = datap->pkg_license[0] ? [NSString stringWithUTF8String:datap->pkg_license] : nil;

   [pool release];


   return(NO);
}


@end