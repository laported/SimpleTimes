//
//  MISwimDBProxy.m
//  ipadsplitview
//
//  Created by David LaPorte on 7/2/11.
//  Copyright 2011 laporte6.org. All rights reserved.
//

#import "USASwimmingDBProxy.h"
#import "ASIFormDataRequest.h"
#import "ROHTMLTable.h"
#import "RaceResultTeamManager.h" 

// URL used to POST form data to get all times with a given stroke and distance
NSString* const usaAllTimesPostUrl = @"http://www.usaswimming.org/DesktopDefault.aspx?TabId=1470&Alias=Rainbow&Lang=en-US";

// http://www.sports-tek.com/TMOnline/aATHRESULTSWithPSMR.ASP?db=upload\MichiganSwimmingLSCOfficeCopy.mdb&ATH=11657&
// Stroke=1&Distance=100&Course=Y&Fastest=&MEET=&Sort=intStroke

//http://www.sports-tek.com/TMOnline/aATHRESULTSWithPSMR.ASP?ATH=11657&Stroke=1&Distance=100&Course=Y&Fastest=&MEET=&STD//=false&DB=upload\MichiganSwimmingLSCOfficeCopy.mdb

/*
 * Posting form via javascript:
 javascript:WebForm_DoPostBackWithOptions(new WebForm_PostBackOptions(&quot;ctl00$ctl63$btnSearch&quot;, &quot;&quot;, true, &quot;&quot;, &quot;&quot;, false, true))
 
 */
/* WOW!!! 17Kb of POST data!!!!! */
NSString* const searchPostData = @"ctl00_RadScriptManager1_TSM=%3B%3BSystem.Web.Extensions%2C+Version%3D3.5.0.0%2C+Culture%3Dneutral%2C+PublicKeyToken%3D31bf3856ad364e35%3Aen%3Afec40ae8-2c1f-4db6-96ca-d6c61af2dc7f%3Aea597d4b%3Ab25378d2%3BTelerik.Web.UI%2C+Version%3D2011.1.519.35%2C+Culture%3Dneutral%2C+PublicKeyToken%3D121fae78165ba3d4%3Aen%3Aa7ce4dad-64d9-443a-ad53-b92c44c63a1c%3A16e4e7cd%3Aed16cbdc%3Af7645509%3A24ee1bba%3Ae330518b%3A1e771326%3Ac8618e41%3Aa1a4383a%3A7c926187%3A8674cba1%3Ab7778d6c%3Ac08e9f8a%3A59462f1%3Aa51ee93e&ctl00_RadStyleSheetManager1_TSSM=%3BTelerik.Web.UI%2C+Version%3D2011.1.519.35%2C+Culture%3Dneutral%2C+PublicKeyToken%3D121fae78165ba3d4%3Aen%3Aa7ce4dad-64d9-443a-ad53-b92c44c63a1c%3Aed2942d4%3A580b2269%3Aaac1aeb7%3Ac73cf106%3Ac86a4a06%3A4c651af2&__EVENTTARGET=ctl00%24ctl63%24btnSearch&__EVENTARGUMENT=&__VIEWSTATE=%2FwEPDwUENTM4MQ8WAh4LVXJsUmVmZXJyZXIFHy9EZXNrdG9wRGVmYXVsdC5hc3B4P1RhYklkPTE0NjQWAmYPZBYCAgMPZBYCAgEPZBYGAgkPZBYCAggPDxYEHgRUZXh0BQxNeSBEZWNrIFBhc3MeC05hdmlnYXRlVXJsBR8vRGVza3RvcERlZmF1bHQuYXNweD9UYWJJZD0yMTQzZGQCDw9kFgQCBw9kFgICAw9kFgQCAQ8WAh4HVmlzaWJsZWhkAgMPZBYIAgEPZBYCAgEPDxYCHwEFIkEgU3BlY2lhbCBNZXNzYWdlIGZyb20gUnlhbiBMb2NodGVkZAIFD2QWAgIBDw8WAh8BBdQCSXQncyBjaGFtcGlvbnNoaXAgbWVldCB0aW1lIGZvciBtb3N0IG9mIEFtZXJpY2EncyBTd2ltIFRlYW0sIGFuZCBSeWFuIExvY2h0ZSBpcyBubyBleGNlcHRpb24uIFJ5YW4gdG9vayBzb21lIHRpbWUgb3V0IG9mIGhpcyB0cmFpbmluZyB0byBzZW5kIGEgc3BlY2lhbCBtZXNzYWdlIHRvIGhpcyBBbWVyaWNhJ3MgU3dpbSBUZWFtIHRlYW1tYXRlcy4gSGF2ZSBhIGxvb2ssIGFuZCB0aGVuIHNlbmQgdGhlIHZpZGVvIG9uIHRvIHlvdXIgZmF2b3JpdGUgQW1lcmljYSdzIFN3aW0gVGVhbSBzd2ltbWVyIGZvciBhIGxpdHRsZSBtb3RpdmF0aW9uIGFzIHRoZXkgcHJlcGFyZSBmb3IgdGhlIGJpZyBtZWV0IWRkAgkPFgQeBXN0eWxlBR92aXNpYmlsaXR5OnZpc2libGU7IGNsZWFyOmJvdGg7HwNnFgICAQ8WBh4GdGFyZ2V0BQVfc2VsZh4JaW5uZXJodG1sBQZXYXRjaCEeBGhyZWYFT2h0dHA6Ly93d3cudXNhc3dpbW1pbmcub3JnL0Rlc2t0b3BEZWZhdWx0LmFzcHg%2FVGFiSWQ9MjEwNiZBbGlhcz1SYWluYm93Jkxhbmc9ZW5kAgsPFgIfBAUgdmlzaWJpbGl0eTpjb2xsYXBzZTsgY2xlYXI6Ym90aDsWAgIBDxYCHwNoZAIID2QWAgICD2QWFmYPDxYCHwEFEVVTQSBTd2ltbWluZyBTaG9wZGQCAQ8PFgIfAQUQR2V0IFlvdXIgR2VhciBPbmRkAgIPFgQeA3NyYwUnL19SYWluYm93L2ltYWdlcy9fU3RvcmUgSW1hZ2VzL3RlZXMucG5nHwNnZAIEDxYMHgtvbm1vdXNlb3ZlcgWpAVVTQVN3aW1taW5nU2hvcFN3YXBJbWFnZSgnY3RsMDBfY3RsNjBfaW1nQ2F0ZWdvcnknLCAnL19SYWluYm93L2ltYWdlcy9fU3RvcmUgSW1hZ2VzL3RlZXMucG5nJyk7IFVTQVN3aW1taW5nU2hvcFN3YXBJbWFnZSgnY3RsMDBfY3RsNjBfaW1nQ2F0ZWdvcnkxJywnLi4vaW1hZ2VzLzF4MS5naWYnKTseCm9ubW91c2VvdXQFSVVTQVN3aW1taW5nU2hvcFN3YXBJbWFnZSgnY3RsMDBfY3RsNjBfaW1nQ2F0ZWdvcnkxJywnLi4vaW1hZ2VzLzF4MS5naWYnKTsfBgUIVC1TaGlydHMfBQUGX2JsYW5rHwcFOmh0dHA6Ly9zaG9wLnVzYXN3aW1taW5nLm9yZy9vbHltcGljc19VU0FfU3dpbW1pbmdfVC1TaGlydHMfA2dkAgYPFgwfCQWsAVVTQVN3aW1taW5nU2hvcFN3YXBJbWFnZSgnY3RsMDBfY3RsNjBfaW1nQ2F0ZWdvcnknLCAnL19SYWluYm93L2ltYWdlcy9fU3RvcmUgSW1hZ2VzL2phY2tldHMucG5nJyk7IFVTQVN3aW1taW5nU2hvcFN3YXBJbWFnZSgnY3RsMDBfY3RsNjBfaW1nQ2F0ZWdvcnkyJywnLi4vaW1hZ2VzLzF4MS5naWYnKTsfCgVJVVNBU3dpbW1pbmdTaG9wU3dhcEltYWdlKCdjdGwwMF9jdGw2MF9pbWdDYXRlZ29yeTInLCcuLi9pbWFnZXMvMXgxLmdpZicpOx8GBQdKYWNrZXRzHwUFBl9ibGFuax8HBTlodHRwOi8vc2hvcC51c2Fzd2ltbWluZy5vcmcvb2x5bXBpY3NfVVNBX1N3aW1taW5nX0phY2tldHMfA2dkAggPFgwfCQWqAVVTQVN3aW1taW5nU2hvcFN3YXBJbWFnZSgnY3RsMDBfY3RsNjBfaW1nQ2F0ZWdvcnknLCAnL19SYWluYm93L2ltYWdlcy9fU3RvcmUgSW1hZ2VzL2Jvb2tzLnBuZycpOyBVU0FTd2ltbWluZ1Nob3BTd2FwSW1hZ2UoJ2N0bDAwX2N0bDYwX2ltZ0NhdGVnb3J5MycsJy4uL2ltYWdlcy8xeDEuZ2lmJyk7HwoFSVVTQVN3aW1taW5nU2hvcFN3YXBJbWFnZSgnY3RsMDBfY3RsNjBfaW1nQ2F0ZWdvcnkzJywnLi4vaW1hZ2VzLzF4MS5naWYnKTsfBgUQQm9va3MgJmFtcDsgRHZkcx8FBQZfYmxhbmsfBwU9aHR0cDovL3Nob3AudXNhc3dpbW1pbmcub3JnL29seW1waWNzX1VTQV9Td2ltbWluZ19BY2Nlc3Nvcmllcx8DZ2QCCg8WDB8JBakBVVNBU3dpbW1pbmdTaG9wU3dhcEltYWdlKCdjdGwwMF9jdGw2MF9pbWdDYXRlZ29yeScsICcvX1JhaW5ib3cvaW1hZ2VzL19TdG9yZSBJbWFnZXMvYmFncy5wbmcnKTsgVVNBU3dpbW1pbmdTaG9wU3dhcEltYWdlKCdjdGwwMF9jdGw2MF9pbWdDYXRlZ29yeTQnLCcuLi9pbWFnZXMvMXgxLmdpZicpOx8KBUlVU0FTd2ltbWluZ1Nob3BTd2FwSW1hZ2UoJ2N0bDAwX2N0bDYwX2ltZ0NhdGVnb3J5NCcsJy4uL2ltYWdlcy8xeDEuZ2lmJyk7HwYFBEJhZ3MfBQUGX2JsYW5rHwcFR2h0dHA6Ly9zaG9wLnVzYXN3aW1taW5nLm9yZy9vbHltcGljc19VU0FfU3dpbW1pbmdfTHVnZ2FnZV9BbmRfU3BvcnRiYWdzHwNnZAIMDxYMHwkFsAFVU0FTd2ltbWluZ1Nob3BTd2FwSW1hZ2UoJ2N0bDAwX2N0bDYwX2ltZ0NhdGVnb3J5JywgJy9fUmFpbmJvdy9pbWFnZXMvX1N0b3JlIEltYWdlcy9zd2VhdHNoaXJ0cy5wbmcnKTsgVVNBU3dpbW1pbmdTaG9wU3dhcEltYWdlKCdjdGwwMF9jdGw2MF9pbWdDYXRlZ29yeTUnLCcuLi9pbWFnZXMvMXgxLmdpZicpOx8KBUlVU0FTd2ltbWluZ1Nob3BTd2FwSW1hZ2UoJ2N0bDAwX2N0bDYwX2ltZ0NhdGVnb3J5NScsJy4uL2ltYWdlcy8xeDEuZ2lmJyk7HwYFC1N3ZWF0c2hpcnRzHwUFBl9ibGFuax8HBUhodHRwOi8vc2hvcC51c2Fzd2ltbWluZy5vcmcvb2x5bXBpY3NfVVNBX1N3aW1taW5nX1N3ZWF0c2hpcnRzX0FuZF9GbGVlY2UfA2dkAg4PFgwfCQWxAVVTQVN3aW1taW5nU2hvcFN3YXBJbWFnZSgnY3RsMDBfY3RsNjBfaW1nQ2F0ZWdvcnknLCAnL19SYWluYm93L2ltYWdlcy9fU3RvcmUgSW1hZ2VzL21lZXRTdXBwbGllcy5wbmcnKTsgVVNBU3dpbW1pbmdTaG9wU3dhcEltYWdlKCdjdGwwMF9jdGw2MF9pbWdDYXRlZ29yeTYnLCcuLi9pbWFnZXMvMXgxLmdpZicpOx8KBUlVU0FTd2ltbWluZ1Nob3BTd2FwSW1hZ2UoJ2N0bDAwX2N0bDYwX2ltZ0NhdGVnb3J5NicsJy4uL2ltYWdlcy8xeDEuZ2lmJyk7HwYFDU1lZXQgU3VwcGxpZXMfBQUGX2JsYW5rHwcFP2h0dHA6Ly9zaG9wLnVzYXN3aW1taW5nLm9yZy9PbHltcGljc19VU0FfU3dpbW1pbmdfTWVldF9TdXBwbGllcx8DZ2QCDw8WBB8EBR92aXNpYmlsaXR5OnZpc2libGU7IGNsZWFyOmJvdGg7HwNnFgICAQ8WBh8FBQZfYmxhbmsfBgUIU2hvcCBOb3cfBwUbaHR0cDovL3Nob3AudXNhc3dpbW1pbmcub3JnZAIQDxYCHwQFIHZpc2liaWxpdHk6Y29sbGFwc2U7IGNsZWFyOmJvdGg7FgICAQ8WAh8DaGQCFQ9kFgICBA9kFhoCAw8PFgIfAWVkZAINDxAPFgIeC18hRGF0YUJvdW5kZ2QQFRcNMjAxMiAoVG9wIDEwKQsyMDExICh5ZWFyKQ0yMDExIChUb3AgMTApCzIwMTAgKFllYXIpDTIwMTAgKFRvcCAxMCkLMjAwOSAoeWVhcikNMjAwOSAoVG9wIDEwKQsyMDA4ICh5ZWFyKQ0yMDA4IChUb3AgMTApCzIwMDcgKHllYXIpDTIwMDcgKFRvcCAxMCkLMjAwNiAoeWVhcikNMjAwNiAoVG9wIDEwKQsyMDA1ICh5ZWFyKQ0yMDA1IChUb3AgMTApCzIwMDQgKHllYXIpDTIwMDQgKFRvcCAxMCkLMjAwMyAoeWVhcikOMjAwMyAoVG9wIDEwKSALMjAwMiAoeWVhcikNMjAwMiAoVG9wIDEwKQsyMDAxICh5ZWFyKQ0yMDAxIChUb3AgMTApFRcCMjMCMjICMjECMjACMTkCMTgCMTcCMTYCMTUCMTQCMTMCMTICMTECMTABOQE4ATcBNgE1ATQBMwEyATEUKwMXZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dkZAIRD2QWBGYPDxYGHhBTaG93UG9wdXBPbkZvY3VzaB4HTWF4RGF0ZQYAWCZerpIvjR4MU2VsZWN0ZWREYXRlZGQWBmYPFCsACA8WCh8NBgBYJl6uki%2BNHwFkHgRTa2luBQdEZWZhdWx0Hg1MYWJlbENzc0NsYXNzBQdyaUxhYmVsHg1PcmlnaW5hbFZhbHVlZWQWBh4FV2lkdGgbAAAAAADAYkABAAAAHghDc3NDbGFzcwURcmlUZXh0Qm94IHJpSG92ZXIeBF8hU0ICggIWBh8SGwAAAAAAwGJAAQAAAB8TBRFyaVRleHRCb3ggcmlFcnJvch8UAoICFgYfEhsAAAAAAMBiQAEAAAAfEwUTcmlUZXh0Qm94IHJpRm9jdXNlZB8UAoICFgYfEhsAAAAAAMBiQAEAAAAfEwUTcmlUZXh0Qm94IHJpRW5hYmxlZB8UAoICFgYfEhsAAAAAAMBiQAEAAAAfEwUUcmlUZXh0Qm94IHJpRGlzYWJsZWQfFAKCAhYGHxIbAAAAAADAYkABAAAAHxMFEXJpVGV4dEJveCByaUVtcHR5HxQCggIWBh8SGwAAAAAAwGJAAQAAAB8TBRByaVRleHRCb3ggcmlSZWFkHxQCggJkAgEPDxYCHwNoZGQCAg8UKwANDxYUBQRNaW5EBgBAVyBTBVEIBQ9SZW5kZXJJbnZpc2libGVnBRBWaWV3U2VsZWN0b3JUZXh0BQF4BRtVc2VDb2x1bW5IZWFkZXJzQXNTZWxlY3RvcnNoBRFFbmFibGVNdWx0aVNlbGVjdGgFA0VSU2gFGFVzZVJvd0hlYWRlcnNBc1NlbGVjdG9yc2gFBE1heEQGAFgmXq6SL40FC1NwZWNpYWxEYXlzDwWSAVRlbGVyaWsuV2ViLlVJLkNhbGVuZGFyLkNvbGxlY3Rpb25zLkNhbGVuZGFyRGF5Q29sbGVjdGlvbiwgVGVsZXJpay5XZWIuVUksIFZlcnNpb249MjAxMS4xLjUxOS4zNSwgQ3VsdHVyZT1uZXV0cmFsLCBQdWJsaWNLZXlUb2tlbj0xMjFmYWU3ODE2NWJhM2Q0FCsAAAUNU2VsZWN0ZWREYXRlcw8FjwFUZWxlcmlrLldlYi5VSS5DYWxlbmRhci5Db2xsZWN0aW9ucy5EYXRlVGltZUNvbGxlY3Rpb24sIFRlbGVyaWsuV2ViLlVJLCBWZXJzaW9uPTIwMTEuMS41MTkuMzUsIEN1bHR1cmU9bmV1dHJhbCwgUHVibGljS2V5VG9rZW49MTIxZmFlNzgxNjViYTNkNBQrAAAPFgIfDwUHRGVmYXVsdGRkFgQfEwULcmNNYWluVGFibGUfFAICFgQfEwUMcmNPdGhlck1vbnRoHxQCAmQWBB8TBQpyY1NlbGVjdGVkHxQCAmQWBB8TBQpyY0Rpc2FibGVkHxQCAhYEHxMFDHJjT3V0T2ZSYW5nZR8UAgIWBB8TBQlyY1dlZWtlbmQfFAICFgQfEwUHcmNIb3Zlch8UAgIWBB8TBTFSYWRDYWxlbmRhck1vbnRoVmlldyBSYWRDYWxlbmRhck1vbnRoVmlld19EZWZhdWx0HxQCAhYEHxMFCXJjVmlld1NlbB8UAgJkAgIPDxYEHhJFbmFibGVDbGllbnRTY3JpcHRoHgdFbmFibGVkaGRkAhMPZBYEZg8PFgYfDGgfDQYAWCZerpIvjR8OZGQWBmYPFCsACA8WCh8NBgBYJl6uki%2BNHwFkHw8FB0RlZmF1bHQfEAUHcmlMYWJlbB8RZWQWBh8SGwAAAAAAwGJAAQAAAB8TBRFyaVRleHRCb3ggcmlIb3Zlch8UAoICFgYfEhsAAAAAAMBiQAEAAAAfEwURcmlUZXh0Qm94IHJpRXJyb3IfFAKCAhYGHxIbAAAAAADAYkABAAAAHxMFE3JpVGV4dEJveCByaUZvY3VzZWQfFAKCAhYGHxIbAAAAAADAYkABAAAAHxMFE3JpVGV4dEJveCByaUVuYWJsZWQfFAKCAhYGHxIbAAAAAADAYkABAAAAHxMFFHJpVGV4dEJveCByaURpc2FibGVkHxQCggIWBh8SGwAAAAAAwGJAAQAAAB8TBRFyaVRleHRCb3ggcmlFbXB0eR8UAoICFgYfEhsAAAAAAMBiQAEAAAAfEwUQcmlUZXh0Qm94IHJpUmVhZB8UAoICZAIBDw8WAh8DaGRkAgIPFCsADQ8WFAUETWluRAYAQFcgUwVRCAUPUmVuZGVySW52aXNpYmxlZwUQVmlld1NlbGVjdG9yVGV4dAUBeAUbVXNlQ29sdW1uSGVhZGVyc0FzU2VsZWN0b3JzaAURRW5hYmxlTXVsdGlTZWxlY3RoBQNFUlNoBRhVc2VSb3dIZWFkZXJzQXNTZWxlY3RvcnNoBQRNYXhEBgBYJl6uki%2BNBQtTcGVjaWFsRGF5cw8FkgFUZWxlcmlrLldlYi5VSS5DYWxlbmRhci5Db2xsZWN0aW9ucy5DYWxlbmRhckRheUNvbGxlY3Rpb24sIFRlbGVyaWsuV2ViLlVJLCBWZXJzaW9uPTIwMTEuMS41MTkuMzUsIEN1bHR1cmU9bmV1dHJhbCwgUHVibGljS2V5VG9rZW49MTIxZmFlNzgxNjViYTNkNBQrAAAFDVNlbGVjdGVkRGF0ZXMPBY8BVGVsZXJpay5XZWIuVUkuQ2FsZW5kYXIuQ29sbGVjdGlvbnMuRGF0ZVRpbWVDb2xsZWN0aW9uLCBUZWxlcmlrLldlYi5VSSwgVmVyc2lvbj0yMDExLjEuNTE5LjM1LCBDdWx0dXJlPW5ldXRyYWwsIFB1YmxpY0tleVRva2VuPTEyMWZhZTc4MTY1YmEzZDQUKwAADxYCHw8FB0RlZmF1bHRkZBYEHxMFC3JjTWFpblRhYmxlHxQCAhYEHxMFDHJjT3RoZXJNb250aB8UAgJkFgQfEwUKcmNTZWxlY3RlZB8UAgJkFgQfEwUKcmNEaXNhYmxlZB8UAgIWBB8TBQxyY091dE9mUmFuZ2UfFAICFgQfEwUJcmNXZWVrZW5kHxQCAhYEHxMFB3JjSG92ZXIfFAICFgQfEwUxUmFkQ2FsZW5kYXJNb250aFZpZXcgUmFkQ2FsZW5kYXJNb250aFZpZXdfRGVmYXVsdB8UAgIWBB8TBQlyY1ZpZXdTZWwfFAICZAICDw8WBB8VaB8WaGRkAh8PZBYGAgEPEA8WBh4ORGF0YVZhbHVlRmllbGQFCGRpc3RhbmNlHg1EYXRhVGV4dEZpZWxkBQhkaXN0YW5jZR8LZ2QQFQ0CNTADMTAwAzIwMAM0MDADNTAwAzgwMAQxMDAwBDE1MDAEMTY1MAQyMDAwBDMwMDAENDAwMAQ1MDAwFQ0CNTADMTAwAzIwMAM0MDADNTAwAzgwMAQxMDAwBDE1MDAEMTY1MAQyMDAwBDMwMDAENDAwMAQ1MDAwFCsDDWdnZ2dnZ2dnZ2dnZ2dkZAIEDxAPFgYfFwUJc3Ryb2tlX2lkHxgFC3N0cm9rZV9jb2RlHwtnZBAVBwJGUgJCSwJCUgJGTAJJTQRGUi1SBU1FRC1SFQcBMQEyATMBNAE1ATYBNxQrAwdnZ2dnZ2dnZGQCBw8QDxYGHxcFCWNvdXJzZV9pZB8YBQtjb3Vyc2VfY29kZR8LZ2QQFQMDTENNA1NDTQNTQ1kVAwEzATIBMRQrAwNnZ2dkZAIhDxBkEBUzA0FsbAExATIBMwE0ATUBNgE3ATgBOQIxMAIxMQIxMgIxMwIxNAIxNQIxNgIxNwIxOAIxOQIyMAIyMQIyMgIyMwIyNAIyNQIyNgIyNwIyOAIyOQIzMAIzMQIzMgIzMwIzNAIzNQIzNgIzNwIzOAIzOQI0MAI0MQI0MgI0MwI0NAI0NQI0NgI0NwI0OAI0OQI1MBUzAAExATIBMwE0ATUBNgE3ATgBOQIxMAIxMQIxMgIxMwIxNAIxNQIxNgIxNwIxOAIxOQIyMAIyMQIyMgIyMwIyNAIyNQIyNgIyNwIyOAIyOQIzMAIzMQIzMgIzMwIzNAIzNQIzNgIzNwIzOAIzOQI0MAI0MQI0MgI0MwI0NAI0NQI0NgI0NwI0OAI0OQI1MBQrAzNnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dkZAIjDxBkEBUzA0FsbAExATIBMwE0ATUBNgE3ATgBOQIxMAIxMQIxMgIxMwIxNAIxNQIxNgIxNwIxOAIxOQIyMAIyMQIyMgIyMwIyNAIyNQIyNgIyNwIyOAIyOQIzMAIzMQIzMgIzMwIzNAIzNQIzNgIzNwIzOAIzOQI0MAI0MQI0MgI0MwI0NAI0NQI0NgI0NwI0OAI0OQI1MBUzAAExATIBMwE0ATUBNgE3ATgBOQIxMAIxMQIxMgIxMwIxNAIxNQIxNgIxNwIxOAIxOQIyMAIyMQIyMgIyMwIyNAIyNQIyNgIyNwIyOAIyOQIzMAIzMQIzMgIzMwIzNAIzNQIzNgIzNwIzOAIzOQI0MAI0MQI0MgI0MwI0NAI0NQI0NgI0NwI0OAI0OQI1MBQrAzNnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dkZAIrDxBkEBUHBUV2ZW50A0FnZQRUaW1lDFBvd2VyIFBvaW50cwhTdGFuZGFyZAlNZWV0IERhdGUUVXNlIEdyaWQgQ29sdW1uIFNvcnQVBwpzb3J0X29yZGVyC3N3aW1tZXJfYWdlCXN3aW1fdGltZRdoeXRla19wb3dlcl9wb2ludHMgZGVzYxNzdGFuZGFyZF9zb3J0X29yZGVyE3N0YXJ0X2RhdGVfc29ydGFibGUEZ3JpZBQrAwdnZ2dnZ2dnZGQCLQ8QZBAVBwAFRXZlbnQDQWdlBFRpbWUMUG93ZXIgUG9pbnRzCFN0YW5kYXJkCU1lZXQgRGF0ZRUHAApzb3J0X29yZGVyC3N3aW1tZXJfYWdlCXN3aW1fdGltZRdoeXRla19wb3dlcl9wb2ludHMgZGVzYxNzdGFuZGFyZF9zb3J0X29yZGVyE3N0YXJ0X2RhdGVfc29ydGFibGUUKwMHZ2dnZ2dnZ2RkAi8PEGQQFQcABUV2ZW50A0FnZQRUaW1lDFBvd2VyIFBvaW50cwhTdGFuZGFyZAlNZWV0IERhdGUVBwAKc29ydF9vcmRlcgtzd2ltbWVyX2FnZQlzd2ltX3RpbWUXaHl0ZWtfcG93ZXJfcG9pbnRzIGRlc2MTc3RhbmRhcmRfc29ydF9vcmRlchNzdGFydF9kYXRlX3NvcnRhYmxlFCsDB2dnZ2dnZ2dkZAIzD2QWBAIDDzwrAAsCAA8WBB4IUGFnZVNpemUCDx4QQ3VycmVudFBhZ2VJbmRleGZkAhYEHg9QYWdlQnV0dG9uQ291bnQCFB8UAoCAgAJkAgUPDxYCHwEFUFdlIGRpZCBub3QgZmluZCBhbnkgcGVyc29ucyB0aGF0IG1hdGNoZWQgdGhlIG5hbWUgaW5mb3JtYXRpb24gdGhhdCB5b3UgcHJvdmlkZWQuZGQCNQ9kFgYCAw88KwALAGQCCQ88KwALAgAPFgQfGQIyHxpmZAIWBB8bAhQfFAKAgIACZAILDw8WAh8BBTBObyByZWNvcmRzIHdlcmUgZm91bmQgZm9yIHRoZSBzZWxlY3RlZCBjcml0ZXJpYS5kZAI3D2QWAgIDD2QWBAICDxBkEBUECUFkb2JlIFBERg5Gb3JtYXR0ZWQgSFRNTAhSYXcgSFRNTA9FeHBvcnQgdG8gRXhjZWwVBAlBZG9iZSBQREYORm9ybWF0dGVkIEhUTUwIUmF3IEhUTUwPRXhwb3J0IHRvIEV4Y2VsFCsDBGdnZ2cWAWZkAgYPFgIfBAWHAW92ZXJmbG93OiBhdXRvOyBoZWlnaHQ6IDYyNXB4OyB3aWR0aDogNjIwcHg7IGJvcmRlci1zdHlsZTogc29saWQ7IGJvcmRlci13aWR0aDogMXB4OyBib3JkZXItY29sb3I6IzY2NjY2NjsgbWFyZ2luLXRvcDoxMHB4OyBwYWRkaW5nOjBweBYCAgEPDxYGHxIbAAAAAABgg0ABAAAAHgZIZWlnaHQbAAAAAACIg0ABAAAAHxQCgANkZBgBBR5fX0NvbnRyb2xzUmVxdWlyZVBvc3RCYWNrS2V5X18WJAUmY3RsMDAkY3RsNjMkdWNSZXBvcnRWaWV3ZXIkdWNXZWJWaWV3ZXIFGmN0bDAwJEhlYWRlcjEkcm1Qb3J0YWxUYWJzBSZjdGwwMCRIZWFkZXIxJHJtUG9ydGFsVGFicyRpMCRpMCRjdGwwMAUmY3RsMDAkSGVhZGVyMSRybVBvcnRhbFRhYnMkaTEkaTAkY3RsMDAFJmN0bDAwJEhlYWRlcjEkcm1Qb3J0YWxUYWJzJGkyJGkwJGN0bDAzBSZjdGwwMCRIZWFkZXIxJHJtUG9ydGFsVGFicyRpMiRpMCRjdGwwNwUmY3RsMDAkSGVhZGVyMSRybVBvcnRhbFRhYnMkaTMkaTAkY3RsMDAFJmN0bDAwJEhlYWRlcjEkcm1Qb3J0YWxUYWJzJGk0JGkwJGN0bDAwBSZjdGwwMCRIZWFkZXIxJHJtUG9ydGFsVGFicyRpNSRpMCRjdGwwMAUmY3RsMDAkSGVhZGVyMSRybVBvcnRhbFRhYnMkaTYkaTAkY3RsMDAFJmN0bDAwJEhlYWRlcjEkcm1Qb3J0YWxUYWJzJGk3JGkwJGN0bDAwBSZjdGwwMCRIZWFkZXIxJHJtUG9ydGFsVGFicyRpOCRpMCRjdGwwMAUmY3RsMDAkSGVhZGVyMSRybVBvcnRhbFRhYnMkaTkkaTAkY3RsMDAFGGN0bDAwJGN0bDYzJHJhZE5hbWVkRGF0ZQUUY3RsMDAkY3RsNjMkcmFkUmFuZ2UFFGN0bDAwJGN0bDYzJHJhZFJhbmdlBSJjdGwwMCRjdGw2MyRkdFN0YXJ0RGF0ZSRyYWRUaGVEYXRlBStjdGwwMCRjdGw2MyRkdFN0YXJ0RGF0ZSRyYWRUaGVEYXRlJGNhbGVuZGFyBStjdGwwMCRjdGw2MyRkdFN0YXJ0RGF0ZSRyYWRUaGVEYXRlJGNhbGVuZGFyBSBjdGwwMCRjdGw2MyRkdEVuZERhdGUkcmFkVGhlRGF0ZQUpY3RsMDAkY3RsNjMkZHRFbmREYXRlJHJhZFRoZURhdGUkY2FsZW5kYXIFKWN0bDAwJGN0bDYzJGR0RW5kRGF0ZSRyYWRUaGVEYXRlJGNhbGVuZGFyBRdjdGwwMCRjdGw2MyRyYWRFdmVudEFsbAUSY3RsMDAkY3RsNjMkcmFkTENNBRJjdGwwMCRjdGw2MyRyYWRMQ00FEmN0bDAwJGN0bDYzJHJhZFNDWQUSY3RsMDAkY3RsNjMkcmFkU0NZBRJjdGwwMCRjdGw2MyRyYWRTQ00FEmN0bDAwJGN0bDYzJHJhZFNDTQUcY3RsMDAkY3RsNjMkcmFkRXZlbnRTcGVjaWZpYwUcY3RsMDAkY3RsNjMkcmFkRXZlbnRTcGVjaWZpYwUXY3RsMDAkY3RsNjMkcmFkQWxsVGltZXMFIWN0bDAwJGN0bDYzJHJhZEZhc3Rlc3RUaW1lQnlFdmVudAUhY3RsMDAkY3RsNjMkcmFkRmFzdGVzdFRpbWVCeUV2ZW50BSRjdGwwMCRjdGw2MyRyYWRGYXN0ZXN0VGltZUJ5RXZlbnRBZ2UFJGN0bDAwJGN0bDYzJHJhZEZhc3Rlc3RUaW1lQnlFdmVudEFnZTr7ecw9p75GBNxFCjNBwsvv%2BL1w&__EVENTVALIDATION=%2FwEWuwECzN7P4AQCoIid9wIChZnpiQwCypfx%2BQoCpqSCgQ8C19Su%2FAMCwNjgeQLA2Nx5AsDY2HkCwNjUeQLB2Lh6AsHYtHoCwdjweQLB2Ox5AsHY6HkCwdjkeQLB2OB5AsHY3HkCwdjYeQLB2NR5AtnYlHoC1tiUegLH2JR6AsTYlHoCxdiUegLC2JR6AsPYlHoCwNiUegLB2JR6At6y4YgCAvb507IJApyut4cNArmd0ZcPArbF5JUFArbF4MkLArbFkMkLAqC9uvYPApPa4PYGArGbh6EBArCbh6EBAr6bh6EBAr2bh6EBAqqbh6EBArGbx5wKArGbs5wKAqiJwOoIArCbx5wKAr%2Bbx5wKAr6bx5wKAr2bx5wKAsusrcsPAsqsrcsPAsmsrcsPAsisrcsPAs%2BsrcsPAs6srcsPAs2srcsPAuXGs6cPAubGs6cPAufGs6cPAs%2FKqfsEAsClg5UIAsGlg5UIAsKlg5UIAsOlg5UIAsSlg5UIAsWlg5UIAsalg5UIAtelg5UIAtilg5UIAsClw5YIAsClz5YIAsCly5YIAsCl95YIAsCl85YIAsCl%2F5YIAsCl%2B5YIAsCl55YIAsClo5UIAsClr5UIAsGlw5YIAsGlz5YIAsGly5YIAsGl95YIAsGl85YIAsGl%2F5YIAsGl%2B5YIAsGl55YIAsGlo5UIAsGlr5UIAsKlw5YIAsKlz5YIAsKly5YIAsKl95YIAsKl85YIAsKl%2F5YIAsKl%2B5YIAsKl55YIAsKlo5UIAsKlr5UIAsOlw5YIAsOlz5YIAsOly5YIAsOl95YIAsOl85YIAsOl%2F5YIAsOl%2B5YIAsOl55YIAsOlo5UIAsOlr5UIAsSlw5YIAtuY1aUGAtT3%2F8sKAtX3%2F8sKAtb3%2F8sKAtf3%2F8sKAtD3%2F8sKAtH3%2F8sKAtL3%2F8sKAsP3%2F8sKAsz3%2F8sKAtT3v8gKAtT3s8gKAtT3t8gKAtT3i8gKAtT3j8gKAtT3g8gKAtT3h8gKAtT3m8gKAtT338sKAtT308sKAtX3v8gKAtX3s8gKAtX3t8gKAtX3i8gKAtX3j8gKAtX3g8gKAtX3h8gKAtX3m8gKAtX338sKAtX308sKAtb3v8gKAtb3s8gKAtb3t8gKAtb3i8gKAtb3j8gKAtb3g8gKAtb3h8gKAtb3m8gKAtb338sKAtb308sKAtf3v8gKAtf3s8gKAtf3t8gKAtf3i8gKAtf3j8gKAtf3g8gKAtf3h8gKAtf3m8gKAtf338sKAtf308sKAtD3v8gKAqG6270CAuexyK4JAsvD7psOAtvSvLcEAqzQ4OsMAve58ZgEAvzr4bsDAumimZYLAtaln6QJAtm5oc8BAt%2Bt4OsBAtvSsLcEAqzQ7OsMAve5%2FZgEAvzr7bsDAumilZYLAtalk6QJAt%2Bt5OsBAtvStLcEAqzQ6OsMAve5%2BZgEAvzr6bsDAumikZYLAtall6QJAtz06ecP%2FJV1iiKGPwzGs4jFEJouGYLNxH8%3D&ctl00%24Header1%24txtSearch=SEARCH&ctl00_Header1_rmPortalTabs_i0_i0_ctl00_ClientState=&ctl00_Header1_rmPortalTabs_i1_i0_ctl00_ClientState=&ctl00_Header1_rmPortalTabs_i2_i0_ctl03_ClientState=&ctl00_Header1_rmPortalTabs_i2_i0_ctl07_ClientState=&ctl00_Header1_rmPortalTabs_i3_i0_ctl00_ClientState=&ctl00_Header1_rmPortalTabs_i4_i0_ctl00_ClientState=&ctl00_Header1_rmPortalTabs_i5_i0_ctl00_ClientState=&ctl00_Header1_rmPortalTabs_i6_i0_ctl00_ClientState=&ctl00_Header1_rmPortalTabs_i7_i0_ctl00_ClientState=&ctl00_Header1_rmPortalTabs_i8_i0_ctl00_ClientState=&ctl00_Header1_rmPortalTabs_i9_i0_ctl00_ClientState=&ctl00_Header1_rmPortalTabs_ClientState=&ctl00%24ctl63%24txtSearchLastName=laporte&ctl00%24ctl63%24txtSearchFirstName=benjamin&ctl00%24ctl63%24DateRange=radNamedDate&ctl00%24ctl63%24ddNamedDateRange=22&ctl00%24ctl63%24dtStartDate%24radTheDate=&ctl00_ctl63_dtStartDate_radTheDate_dateInput_text=&ctl00%24ctl63%24dtStartDate%24radTheDate%24dateInput=&ctl00_ctl63_dtStartDate_radTheDate_dateInput_ClientState=%7B%22enabled%22%3Atrue%2C%22emptyMessage%22%3A%22%22%2C%22minDateStr%22%3A%221%2F1%2F1900+0%3A0%3A0%22%2C%22maxDateStr%22%3A%2211%2F16%2F3011+0%3A0%3A0%22%7D&ctl00_ctl63_dtStartDate_radTheDate_calendar_SD=%5B%5D&ctl00_ctl63_dtStartDate_radTheDate_calendar_AD=%5B%5B1900%2C1%2C1%5D%2C%5B3011%2C11%2C16%5D%2C%5B2011%2C11%2C16%5D%5D&ctl00_ctl63_dtStartDate_radTheDate_ClientState=%7B%22minDateStr%22%3A%221%2F1%2F1900+0%3A0%3A0%22%2C%22maxDateStr%22%3A%2211%2F16%2F3011+0%3A0%3A0%22%7D&ctl00%24ctl63%24dtEndDate%24radTheDate=&ctl00_ctl63_dtEndDate_radTheDate_dateInput_text=&ctl00%24ctl63%24dtEndDate%24radTheDate%24dateInput=&ctl00_ctl63_dtEndDate_radTheDate_dateInput_ClientState=%7B%22enabled%22%3Atrue%2C%22emptyMessage%22%3A%22%22%2C%22minDateStr%22%3A%221%2F1%2F1900+0%3A0%3A0%22%2C%22maxDateStr%22%3A%2211%2F16%2F3011+0%3A0%3A0%22%7D&ctl00_ctl63_dtEndDate_radTheDate_calendar_SD=%5B%5D&ctl00_ctl63_dtEndDate_radTheDate_calendar_AD=%5B%5B1900%2C1%2C1%5D%2C%5B3011%2C11%2C16%5D%2C%5B2011%2C11%2C16%5D%5D&ctl00_ctl63_dtEndDate_radTheDate_ClientState=%7B%22minDateStr%22%3A%221%2F1%2F1900+0%3A0%3A0%22%2C%22maxDateStr%22%3A%2211%2F16%2F3011+0%3A0%3A0%22%7D&ctl00%24ctl63%24Event=radEventAll&ctl00%24ctl63%24DSCCtl%24ddDistance=50&ctl00%24ctl63%24DSCCtl%24ddStroke=1&ctl00%24ctl63%24DSCCtl%24ddCourse=3&ctl00%24ctl63%24ddAgeStart=&ctl00%24ctl63%24ddAgeEnd=&ctl00%24ctl63%24FastTimes=radAllTimes&ctl00%24ctl63%24ddlSortBy1=sort_order&ctl00%24ctl63%24ddlSortBy2=&ctl00%24ctl63%24ddlSortBy3=";

NSString* const searchPostDataMin = @"ctl00%24ctl63%24txtSearchLastName=laporte&ctl00%24ctl63%24txtSearchFirstName=benjamin&ctl00%24ctl63%24DateRange=radNamedDate&ctl00%24ctl63%24ddNamedDateRange=22&ctl00%24ctl63%24dtStartDate%24radTheDate=&ctl00_ctl63_dtStartDate_radTheDate_dateInput_text=&ctl00%24ctl63%24dtStartDate%24radTheDate%24dateInput=&ctl00_ctl63_dtStartDate_radTheDate_dateInput_ClientState=%7B%22enabled%22%3Atrue%2C%22emptyMessage%22%3A%22%22%2C%22minDateStr%22%3A%221%2F1%2F1900+0%3A0%3A0%22%2C%22maxDateStr%22%3A%2211%2F16%2F3011+0%3A0%3A0%22%7D&ctl00_ctl63_dtStartDate_radTheDate_calendar_SD=%5B%5D&ctl00_ctl63_dtStartDate_radTheDate_calendar_AD=%5B%5B1900%2C1%2C1%5D%2C%5B3011%2C11%2C16%5D%2C%5B2011%2C11%2C16%5D%5D&ctl00_ctl63_dtStartDate_radTheDate_ClientState=%7B%22minDateStr%22%3A%221%2F1%2F1900+0%3A0%3A0%22%2C%22maxDateStr%22%3A%2211%2F16%2F3011+0%3A0%3A0%22%7D&ctl00%24ctl63%24dtEndDate%24radTheDate=&ctl00_ctl63_dtEndDate_radTheDate_dateInput_text=&ctl00%24ctl63%24dtEndDate%24radTheDate%24dateInput=&ctl00_ctl63_dtEndDate_radTheDate_dateInput_ClientState=%7B%22enabled%22%3Atrue%2C%22emptyMessage%22%3A%22%22%2C%22minDateStr%22%3A%221%2F1%2F1900+0%3A0%3A0%22%2C%22maxDateStr%22%3A%2211%2F16%2F3011+0%3A0%3A0%22%7D&ctl00_ctl63_dtEndDate_radTheDate_calendar_SD=%5B%5D&ctl00_ctl63_dtEndDate_radTheDate_calendar_AD=%5B%5B1900%2C1%2C1%5D%2C%5B3011%2C11%2C16%5D%2C%5B2011%2C11%2C16%5D%5D&ctl00_ctl63_dtEndDate_radTheDate_ClientState=%7B%22minDateStr%22%3A%221%2F1%2F1900+0%3A0%3A0%22%2C%22maxDateStr%22%3A%2211%2F16%2F3011+0%3A0%3A0%22%7D&ctl00%24ctl63%24Event=radEventAll&ctl00%24ctl63%24DSCCtl%24ddDistance=50&ctl00%24ctl63%24DSCCtl%24ddStroke=1&ctl00%24ctl63%24DSCCtl%24ddCourse=3&ctl00%24ctl63%24ddAgeStart=&ctl00%24ctl63%24ddAgeEnd=&ctl00%24ctl63%24FastTimes=radAllTimes&ctl00%24ctl63%24ddlSortBy1=sort_order&ctl00%24ctl63%24ddlSortBy2=&ctl00%24ctl63%24ddlSortBy3=";

@implementation USASwimmingDBProxy

- (NSString *)enumAllAthletes:(NSString*)lastnamefirstletter {
/* TODO
    NSString *sQuery = [NSString stringWithFormat:usaAthletesQuery,[lastnamefirstletter characterAtIndex:0]];
    NSString *sQueryUrl = sQuery; //[sQuery stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(sQueryUrl);
    NSURL *urlQuery = [NSURL URLWithString:sQueryUrl];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:urlQuery];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        NSString *response = [request responseString];
        [self testRowParser:response];
        return response;
    } else {
        return @"";
    }
*/ return @"";
}

- (int)saveFile:(NSString*)text
{
    NSArray  *myPathList =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *myPath     =  [myPathList  objectAtIndex:0];
    NSError  **err;
    int rc = 0;
    
    myPath = [myPath stringByAppendingPathComponent:@"USATestTimes.html"];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:myPath])        
    {
        [[NSFileManager defaultManager] createFileAtPath:myPath contents:nil attributes:nil];        
        [text writeToFile:myPath atomically:NO encoding:NSUTF8StringEncoding error:err];        
    }
    else        
    {
        NSLog(@"Cannot overwrite existing files");     
        rc = -1;
    }
    return rc;
}

- (NSString*)loadFile:(NSString*)filename
{
    NSArray  *myPathList =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *myPath     =  [myPathList  objectAtIndex:0];
    NSError  **err;
    NSString *text = NULL;
    
    myPath = [myPath stringByAppendingPathComponent:filename];
    if([[NSFileManager defaultManager] fileExistsAtPath:myPath]) {        
        text = [NSString stringWithContentsOfFile:myPath encoding:NSUTF8StringEncoding error:err];
    } 
    else {
        NSLog(@"Errore");
    }
    return text;
}

#define USAONLINETESTING

- (NSArray*)getAllTimesForAthlete:(int)athleteId {
    return [self getAllTimesForAthlete:athleteId stroke:0 distance:0];
}

- (NSArray *)getAllTimesForAthlete:(int)athleteId stroke:(int)stroke distance:(int)distance {

    NSMutableArray* all_times = [NSMutableArray array];
    NSArray *sorted_results = nil;
    BOOL requestOK = YES;
    NSString* response = NULL;
    
#if defined (USAONLINETESTING)
    NSString *sPostUrl;
    if (stroke == 0 && distance == 0) {
        NSLog(@"ERROR! Must supply stroke and distance values for USASwimming:getAllTikmesFotAthlete");
        return NULL;
    } else {
        sPostUrl = usaAllTimesPostUrl; //[NSString stringWithFormat:[usaAllTimesPostUrl]]; //],athleteId,stroke,distance];
    }
    NSLog(@"%@", sPostUrl);
    NSURL *urlPost = [NSURL URLWithString:sPostUrl];
    
    // Grab the times from the website
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:urlPost];
    [request appendPostData:[searchPostDataMin dataUsingEncoding:NSUTF8StringEncoding]];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        response = [request responseString];
    } else {
        requestOK = NO;
    }
#else
    response = [self loadFile:@"USATestTimes.html"];
#endif
    if (requestOK == YES) {    
        // Extract the <TABLE> element containing the times
        [self saveFile:response];
        NSString *table = [self getTimesTable:response];
        NSLog(@"%@", table);
        
        // Parse the table
        ROHTMLTable* parser = [[ROHTMLTable alloc] init];
        [parser initFromString:table];
        
        // Column defs
        // 0 Link to splits data
        // 1 Distance
        // 2 Stroke
        // 3 P/F ?????
        // 4 Time
        // 5 Place
        // 6 Points
        // 7 Date
        // 8 Meet
        for (int i=0;i<[parser numRows];i++) {
            NSLog(@"Meet: %@ / %@\n",[parser cell:i col:7],[parser cell:i col:8]);
            NSLog(@"   %@ %@ %@\n\n",[parser cell:i col:1],[parser cell:i col:2],[parser cell:i col:4]);
            
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"MM/dd/yyyy"];
            NSDate *myDate = [df dateFromString:[parser cell:i col:7]];
            
            if (myDate != nil) {
/* TODO: USA Swimming results
               RaceResultTeamManager* race = [[[RaceResultTeamManager alloc] initWithTime:[parser cell:i col:4]
                           meet:[parser cell:i col:8]
                                                               date:myDate
                                                             stroke:[parser cell:i col:2]
                                                           distance:[[parser cell:i col:1] intValue]
                                    ] autorelease];
 
 - (id)initWithTime:(NSString*)time meet:(NSString*)meet date:(NSDate*)date stroke:(NSString*)stroke distance:(int)distance course:(NSString*)course age:(int)age powerpoints:(int)powerpoints standard:(NSString*)standard splits:(NSArray*)splits db:(NSString*)db;
               [all_times addObject:race];
 */
            }
        
        }
        // new and shiny sorted array
        sorted_results = [all_times sortedArrayUsingSelector:@selector(compareByTime:)];        
    }     
   
    // RETURN ARRAY OF RaceResultTeamManager Objects sorted by time
    
    return sorted_results;
}

- (NSArray *)findAthlete:(NSString*)lastname {
    return [self findAthlete:@""];
}

- (NSArray *)findAthlete:(NSString*)lastname firstname:(NSString*)firstname {
    return NULL;
    /*
    NSString *sQuery = [NSString stringWithFormat:usaAthleteQuery,lastname];
    NSString *sQueryUrl = sQuery; 
    NSLog(sQueryUrl);
    NSURL *urlQuery = [NSURL URLWithString:sQueryUrl];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:urlQuery];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        NSString *response = [request responseString];
        NSString *table = [self getAthleteTable:response];
        
        // todo NSArray* swimmers = [[XlatHTMLAth2Swimmers alloc] initWithString:table];
        //[self testRowParser:response];
        return response;
    } else {
        return @"";
    }
  */  
}

/*
 * This code grabs the table showing athlete info. The table looks something like:
 
 <TABLE summary="Athletes" border="0" cellspacing="1" cellpadding="2" bgcolor="#000000" id=FieldTable width="740">
 <TR bgcolor="#6699CC" color="#FFFFFF"> 
 <TH scope="col" width="40" align=center class="TopRow">&nbsp;</Th>
 <TH scope="col" width="100" align=center class="TopRow">Last</Th>
 <TH scope="col" width ="100" align=center class="TopRow">First</TH>
 <TH scope="col" width="27" align=center class="TopRow">Age</TH>
 <TH scope="col" width="27" align=center class="TopRow">Gen</TH>
 <TH scope="col" width="30" align=center class="TopRow">Gr</TH>
 <TH scope="col" width="30" align=center class="TopRow">Sub</TH>
 <TH scope="col" width="30" align=center class="TopRow">YR</TH>
 <th scope="col" width="61" align=center class="TopRow"> &nbsp;&nbsp;Team</th>
 <TH scope="col" width="220" align=center class="TopRow">&nbsp;&nbsp;Full Team Name</TH>
 </TR>
 <!-- Display the data rows. -->
 
 
 
 <TR> 
 <TD align=right bgcolor="#FFFFFF" class="trow" width="40"><a href="aATHRESULTSWithPSMR.ASP?db=upload\MichiganSwimmingLSCOfficeCopy.mdb&ATH=12594&FASTEST=1">Times</a></TD>
 <TD bgcolor="#FFFFFF"  align=left class="trow" width="100">LaPorte</TD>
 <TD   bgcolor="#FFFFFF"  align=left class="trow" width="100">
 Adam</TD>
 <TD  bgcolor="#FFFFFF"  align=RIGHT class="trow" width="27">
 19&nbsp;</TD>
 <TD bgcolor="#FFFFFF"  align=center class="trow" width="27">
 M</TD>
 <TD  bgcolor="#FFFFFF"  align=left class="trow" width="30">
 &nbsp;</TD>
 <TD  bgcolor="#FFFFFF"  align=left class="trow" width="30">
 &nbsp;</TD>
 <TD  bgcolor="#FFFFFF"  align=center class="trow" width="30">
 &nbsp;</TD>
 <TD  bgcolor="#FFFFFF" align=right class="trow" width="61">
 LCSC</TD>
 <TD  bgcolor="#FFFFFF" align=left class="trow" width="220">
 Livonia Community Swim Club</TD>
 </TR>
 ...
 possibly more athlete rows
 */
- (NSString *) getAthleteTable:(NSString *)srcString {
    NSString* prefix = @"<TABLE summary=\"Athletes\"";
    NSString* postfix =  @"</TABLE>";
    NSString* table = [self extractElementFromString:srcString prefix:prefix postfix:postfix];
	return table;
}

- (NSString *)extractElementFromString:(NSString*)source prefix:(NSString*)prefix postfix:(NSString*)postfix {
    NSRange start = [source rangeOfString:prefix options:(NSCaseInsensitiveSearch)];
    NSRange end;
    if (start.location != NSNotFound) {
        // chop off the source string before the match
        start.length = [source length] - start.location;
        NSString* s1 = [source substringWithRange:start]; 
        // search for postfix
        end = [s1 rangeOfString:postfix options:(NSCaseInsensitiveSearch)];
        if (end.location != NSNotFound) {
            // Chop off characters after the postfix
            end.length = end.location + [postfix length];
            end.location = 0;
            NSString* s2 = [s1 substringWithRange:end];
            return s2;
        } else {
            NSLog(@"!!extractElementFromString postfix:'%@' NOT FOUND!!",postfix);
        }
    } else {
        NSLog(@"!!extractElementFromString prefix:'%@' NOT FOUND!!",prefix);
    }
    return NULL;
}
        

// Columns:
// 0 Link to splits data
// 1 Distance
// 2 Stroke
// 3 P/F ?????
// 4 Time
// 5 Place
// 6 Points
// 7 Date
// 8 Meet
-(NSString*)getTimesTable:(NSString*)srcString {
    NSString* prefix = @"<table cellspacing=\"0\" cellpadding=\"2\" rules=\"all\" border=\"1\" id=\"ctl00_ctl63_dgSearchResults\" style=\"width:100%;border-collapse:collapse;\">";
    NSString* postfix =  @"</table>";
    NSString* table = [self extractElementFromString:srcString prefix:prefix postfix:postfix];
    if (table == NULL) {
        NSLog(@"ERROR: Did not find table. Dumping srcString (%d bytes)...",[srcString length]);
        NSLog(@"%@", srcString);
    }
	return table;
}

@end
