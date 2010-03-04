package Test::AssetBase;
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use lib "$FindBin::Bin/lib";

use WebGUI::Test;

use base qw/Test::Class/;
use Test::More;
use Test::Deep;
use Test::Exception;
use WebGUI::Exception;

sub session {
     return shift->{_session};
}

sub class {
     return qw/WebGUI::Asset/;
}

sub assetUiLevel {
     return 1;
}

sub _00_init : Test(startup) {
    my $test = shift;
    my $session = WebGUI::Test->session;
    $test->{_session} = $session;
    eval { require $test->class; };
}

sub constructor : Test(4) {
    my $test    = shift;
    my $session = $test->session;
    my $asset = $test->class->new({session => $session});

    isa_ok $asset, $test->class;
    isa_ok $asset->session, 'WebGUI::Session';
    is $asset->session->getId, $session->getId, 'asset was assigned the correct session';

    note "calling new with no assetId throws an exception";
    $asset = eval { WebGUI::Asset->new($session, ''); };
    my $e = Exception::Class->caught;
    isa_ok $e, 'WebGUI::Error';
}

sub title : Test(6) {
    my $test    = shift;
    my $session = $test->session;
    my $asset   = $test->class->new({session => $session});

    note "title";
    can_ok $asset, 'title';
    is $asset->title, 'Untitled', 'title: default is untitled';

    $asset->title('asset title');
    is $asset->title, 'asset title', '... set, get';
    $asset->title('');
    is $asset->title, 'Untitled', '... get default title when empty title set';
    $asset->title('<h1>Header</h1>text');
    is $asset->title, 'Headertext', '... HTML is filtered out';
    $asset->title('<h1></h1>');
    is $asset->title, 'Untitled', '... if HTML filters out all, returns default';

    #is $asset->get('title'), $asset->title, '... get(title) works';

}

sub menuTitle : Test(8) {
    my $test    = shift;
    my $session = $test->session;
    my $asset = $test->class->new({session => $session});

    note "menuTitle";

    can_ok $asset, 'menuTitle';
    is $asset->menuTitle, 'Untitled', 'menuTitle: default is untitled';

    $asset = $test->class->new({
        session => $session,
        title   => 'asset title',
    });

    is $asset->menuTitle, 'asset title', 'menuTitle: default is title';

    $asset->menuTitle('asset menuTitle');
    is $asset->menuTitle, 'asset menuTitle', '... set and get';

    $asset->menuTitle('');
    is $asset->menuTitle, 'asset title', '... set to default when trying to clear the title';

    $asset->menuTitle('<h1>Header</h1>text');
    is $asset->menuTitle, 'Headertext', '... HTML is filtered out';
    $asset->menuTitle('<h1></h1>');
    is $asset->menuTitle, 'asset title', '... if HTML filters out all, returns default';

    $asset = $test->class->new({
        session   => $session,
        title     => 'asset title',
        menuTitle => 'menuTitle asset',
    });
    is $asset->menuTitle, 'menuTitle asset', '... set via constructor';
}

sub assetId : Test(4) {
    my $test    = shift;
    my $session = $test->session;
    my $asset   = $test->class->new({session => $session});
    note "assetId, getId";
    can_ok $asset, qw/assetId getId/;
    ok $session->id->valid( $asset->assetId), 'assetId generated by default is valid';
    is $asset->assetId, $asset->getId, '... getId is an alias for assetId';

    $asset = $test->class->new({ session => $session, assetId => '' });
    ok $session->id->valid($asset->assetId), 'blank assetid in constructor causes an assetId to be generated';
}

sub class_dispatch : Test(2) {
    my $test    = shift;
    my $session = $test->session;
    note "Class dispatch";
    my $asset   = $test->class->new({session => $session});

    my $asset = WebGUI::Asset->new({
        session   => $session,
        title     => 'testing snippet',
        className => 'WebGUI::Asset::Snippet',
    });

    isa_ok $asset, 'WebGUI::Asset';
    is $asset->className, 'WebGUI::Asset', 'passing className is ignored';
}

sub uiLevel : Test(1) {
    my $test    = shift;
    my $session = $test->session;
    note "uiLevel";
    is $test->class->meta->uiLevel, $test->assetUiLevel, 'asset uiLevel check';
}

sub write_update : Test(8) {
    my $test    = shift;
    my $session = $test->session;
    note "write, update";

    my $testId       = 'wg8TestAsset0000000001';
    my $revisionDate = time();
    $session->db->write("insert into asset (assetId) VALUES (?)", [$testId]);
    $session->db->write("insert into assetData (assetId, revisionDate) VALUES (?,?)", [$testId, $revisionDate]);

    my $testAsset = WebGUI::Asset->new($session, $testId, $revisionDate);
    $testAsset->title('wg8 test title');
    $testAsset->lastModified(0);
    is $testAsset->assetSize, 0, 'assetSize is 0 by default';
    $testAsset->write();
    isnt $testAsset->lastModified, 0, 'lastModified updated on write';
    isnt $testAsset->assetSize,    0, 'assetSize    updated on write';

    my $testData = $session->db->quickHashRef('select * from assetData where assetId=? and revisionDate=?',[$testId, $revisionDate]);
    is $testData->{title}, 'wg8 test title', 'data written correctly to db';

    $testAsset->update({
        isHidden    => 1,
        encryptPage => 1,
    });

    is $testAsset->isHidden,    1, 'isHidden set via update';
    is $testAsset->encryptPage, 1, 'encryptPage set via update';

    $testData = $session->db->quickHashRef('select * from assetData where assetId=? and revisionDate=?',[$testId, $revisionDate]);
    is $testData->{isHidden},    1, 'isHidden written correctly to db';
    is $testData->{encryptPage}, 1, 'encryptPage written correctly to db';

    $session->db->write("delete from asset where assetId=?", [$testId]);
    $session->db->write("delete from assetData where assetId=?", [$testId]);
}

sub keywords : Test(3) {
    my $test    = shift;
    my $session = $test->session;
    note "keywords";
    my $default = WebGUI::Asset->getDefault($session);
    my $asset = $default->addChild({
        className => $test->class,
    });
    addToCleanup($asset);
    can_ok($asset, 'keywords');
    $asset->keywords('chess set');
    is ($asset->keywords, 'chess set', 'set and get of keywords via direct accessor');
    #is ($asset->get('keywords'), 'chess set', 'via get method');
}

1;

__END__

{
    note "Property inspection";
    my $asset = WebGUI::Asset->new({
        session   => $session,
    });

    cmp_deeply(
        [$asset->meta->get_all_properties],
        array_each(
            methods(
                tableName => 'assetData',
            )
        ),
        'all properties have the right tableName'
    );

}

{
    note "getClassById";
    my $class;
    $class = WebGUI::Asset->getClassById($session, 'PBasset000000000000001');
    is $class, 'WebGUI::Asset', 'getClassById: retrieve a class';
    $class = WebGUI::Asset->getClassById($session, 'PBasset000000000000001');
    is $class, 'WebGUI::Asset', '... cache check';
    $class = WebGUI::Asset->getClassById($session, 'PBasset000000000000002');
    is $class, 'WebGUI::Asset::Wobject::Folder', '... retrieve another class';
}

{
    note "newByPropertyHashRef";
    my $asset;
    $asset = WebGUI::Asset->newByPropertyHashRef($session, {className => 'WebGUI::Asset::Snippet', title => 'The Shawshank Snippet'});
    isa_ok $asset, 'WebGUI::Asset::Snippet';
    is $asset->title, 'The Shawshank Snippet', 'title is assigned from the property hash';

    my $a2 = WebGUI::Asset::Snippet->newByPropertyHashRef($session, {});
    isa_ok $asset, 'WebGUI::Asset::Snippet';
}

{
    note "new, fetching from db";
    my $asset;
    $asset = WebGUI::Asset->new($session, 'PBasset000000000000001');
    isa_ok $asset, 'WebGUI::Asset';
    is $asset->title, 'Root', 'got the right asset';
}

{
    note "getParent";
    my $testId1      = 'wg8TestAsset0000000001';
    my $testId2      = 'wg8TestAsset0000000002';
    my $now          = time();
    my $baseLineage  = $session->db->quickScalar('select lineage from asset where assetId=?',['PBasset000000000000002']);
    my $testLineage  = $baseLineage. '909090';
    $session->db->write("insert into asset (assetId, className, lineage) VALUES (?,?,?)",       [$testId1, 'WebGUI::Asset', $testLineage]);
    $session->db->write("insert into assetData (assetId, revisionDate, status) VALUES (?,?,?)", [$testId1, $now, 'approved']);
    my $testLineage2 = $testLineage . '000001';
    $session->db->write("insert into asset (assetId, className, parentId, lineage) VALUES (?,?,?,?)", [$testId2, 'WebGUI::Asset', $testId1, $testLineage2]);
    $session->db->write("insert into assetData (assetId, revisionDate) VALUES (?,?)", [$testId2, $now]);

    my $testAsset = WebGUI::Asset->new($session, $testId2, $now);
    is $testAsset->parentId, $testId1, 'parentId assigned correctly on db fetch in new';
    my $testParent = $testAsset->getParent();
    isa_ok $testParent, 'WebGUI::Asset';

    $session->db->write("delete from asset where assetId like 'wg8TestAsset00000%'");
    $session->db->write("delete from assetData where assetId like 'wg8TestAsset00000%'");
}

{
    note "addRevision";
    my $testId1      = 'wg8TestAsset0000000001';
    my $testId2      = 'wg8TestAsset0000000002';
    my $now          = time();
    my $revisionDate = $now - 50;
    my $baseLineage  = $session->db->quickScalar('select lineage from asset where assetId=?',['PBasset000000000000002']);
    my $testLineage  = $baseLineage. '909090';
    $session->db->write("insert into asset (assetId, className, lineage) VALUES (?,?,?)",       [$testId1, 'WebGUI::Asset', $testLineage]);
    $session->db->write("insert into assetData (assetId, revisionDate, status) VALUES (?,?,?)", [$testId1, $revisionDate, 'approved']);
    my $testLineage2 = $testLineage . '000001';
    $session->db->write("insert into asset (assetId, className, parentId, lineage) VALUES (?,?,?,?)", [$testId2, 'WebGUI::Asset', $testId1, $testLineage2]);
    $session->db->write("insert into assetData (assetId, revisionDate) VALUES (?,?)", [$testId2, $revisionDate]);

    my $testAsset = WebGUI::Asset->new($session, $testId2, $revisionDate);
    $testAsset->title('test title 43');
    $testAsset->write();
    my $tag = WebGUI::VersionTag->getWorking($session);
    my $revAsset  = $testAsset->addRevision({}, $now);
    isa_ok $revAsset, 'WebGUI::Asset';
    is $revAsset->revisionDate, $now, 'revisionDate set correctly on new revision';
    is $revAsset->title, 'test title 43', 'data fetch from database correct';
    is $revAsset->revisedBy, $session->user->userId, 'revisedBy is current session user';
    is $revAsset->tagId, $tag->getId, 'tagId is current working tagId';
    my $count = $session->db->quickScalar('SELECT COUNT(*) from assetData where assetId=?',[$testId2]);
    is $count, 2, 'two records in the database';
    addToCleanup($tag);

    $session->db->write("delete from asset where assetId like 'wg8TestAsset00000%'");
    $session->db->write("delete from assetData where assetId like 'wg8TestAsset00000%'");
}

{
    note "get_tables, with inheritance";
    use WebGUI::Asset::Snippet;
    my @tables = WebGUI::Asset::Snippet->meta->get_tables;
    cmp_deeply(
        \@tables,
        [qw/assetData snippet/],
        'get_tables works on inherited classes'
    );
}

{
    note "getDefault";
    my $asset = WebGUI::Asset->getDefault($session);
    isa_ok $asset, 'WebGUI::Asset::Wobject::Layout';
}

{
}

{
    note "get gets WebGUI::Definition properties, and standard attributes";
    my $asset = WebGUI::Asset->new({session => $session, parentId => 'I have a parent'});
    is $asset->get('className'), 'WebGUI::Asset', 'get(property) works on className';
    is $asset->get('assetId'),  $asset->assetId,   '... works on assetId';
    is $asset->get('parentId'), 'I have a parent',  '... works on parentId';
    my $properties = $asset->get();
    is $properties->{className}, 'WebGUI::Asset', 'get() works on className';
    is $properties->{assetId},  $asset->assetId,   '... works on assetId';
    is $properties->{parentId}, 'I have a parent',  '... works on parentId';
}


