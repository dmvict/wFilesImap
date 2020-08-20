( function _Imap_test_ss_( ) {

'use strict';

if( typeof module !== 'undefined' )
{
  let _ = require( '../../../wtools/Tools.s' );

  _.include( 'wTesting' );
  _.include( 'wResolver' );
  _.include( 'wCensorBasic' );

  require( '../l4_files/entry/Imap.ss' );
}

let _ = _global_.wTools;

// --
// context
// --

function onSuiteBegin( test )
{
  let context = this;
  context.suiteTempPath = _.fileProvider.path.tempOpen( _.fileProvider.path.join( __dirname, '../..'  ), 'FileProviderImap' );
}

//

function onSuiteEnd( test )
{
  let context = this;
  _.fileProvider.path.tempClose( context.suiteTempPath );
}

//

function providerMake()
{
  let context = this;

  let config = _.censor.configRead();
  let cred = _.resolver.resolve({ selector : context.cred, src : config });

  let providers = Object.create( null );
  providers.effective = providers.imap = _.FileProvider.Imap( cred );
  providers.hd = _.FileProvider.HardDrive();
  providers.extract = _.FileProvider.Extract({ protocols : [ 'extract' ] });
  providers.system = _.FileProvider.System({ providers : [ providers.effective, providers.hd, providers.extract ] });

  // let provider = _.FileProvider.Extract({ protocols : [ 'current', 'second' ] });
  // let system = _.FileProvider.System({ providers : [ provider ] }); /* xxx : try without the system ? */
  // _.assert( system.defaultProvider === null );

  return providers;
}

// --
// tests
// --

function dirRead( test )
{
  let context = this;
  let providers = context.providerMake();

  /* */

  var exp = [ 'Drafts', 'hr', 'INBOX', 'Junk', 'reports', 'Sent', 'system', 'Templates', 'Trash' ];
  var got = providers.effective.dirRead( '/' );
  test.identical( got, exp );

  /* */

  var exp = [ '1-new', '2-contacted', '2-men', '3-video', '5-interesting', '9-no' ];
  var got = providers.effective.dirRead( '/hr' );
  test.identical( got, exp );

  /* */

  var got = providers.effective.dirRead( '/hr/1-new' );
  test.ge( got.length, 3 );

  /* */

  var exp = null;
  var got = providers.effective.dirRead( '/doesNotExists' );
  test.identical( got, exp );

  var exp = null;
  var got = providers.effective.dirRead( '/file/does/not/exist' );
  test.identical( got, exp );

  /* */

  providers.effective.ready.finally( () => providers.effective.unform() );
  return providers.effective.ready;
}

// --
// declare
// --

var Proto =
{

  name : 'Tools.mid.files.fileProvider.Imap',
  silencing : 1,
  enabled : 1,
  routineTimeOut : 60000,

  onSuiteBegin,
  onSuiteEnd,

  context :
  {
    providerMake,
    suiteTempPath : null,
    cred :
    {
      login : 'about/email.login',
      password : 'about/email.password',
      hostUri : 'about/email.imap',
    }
  },

  tests :
  {

    dirRead,

  },

}

//

let Self = new wTestSuite( Proto )
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();