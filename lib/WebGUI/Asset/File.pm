package WebGUI::Asset::File;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2005 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::Asset;
use WebGUI::HTTP;
use WebGUI::Session;
use WebGUI::Storage;
use WebGUI::SQL;

our @ISA = qw(WebGUI::Asset);


=head1 NAME

Package WebGUI::Asset::File

=head1 DESCRIPTION

Provides a mechanism to upload files to WebGUI.

=head1 SYNOPSIS

use WebGUI::Asset::File;


=head1 METHODS

These methods are available from this class:

=cut



#-------------------------------------------------------------------

=head2 addRevision

Override the default method in order to deal with attachments.

=cut

sub addRevision {
	my $self = shift;
	my $newSelf = $self->SUPER::addRevision(@_);
	if ($self->get("storageId")) {
		my $newStorage = WebGUI::Storage->get($self->get("storageId"))->copy;
		$newSelf->update({storageId=>$newStorage->getId});
	}
	return $newSelf;
}

#-------------------------------------------------------------------

=head2 definition ( definition )

Defines the properties of this asset.

=head3 definition

A hash reference passed in from a subclass definition.

=cut

sub definition {
        my $class = shift;
        my $definition = shift;
        push(@{$definition}, {
		assetName=>WebGUI::International::get('assetName',"Asset_File"),
                tableName=>'FileAsset',
                className=>'WebGUI::Asset::File',
                properties=>{
                                filename=>{
					noFormPost=>1,
                                        fieldType=>'hidden',
                                        defaultValue=>undef
                                        },
				storageId=>{
					noFormPost=>1,
					fieldType=>'hidden',
					defaultValue=>undef
					},
				templateId=>{
					fieldType=>'template',
					defaultValue=>'PBtmpl0000000000000024'
					}
                        }
                });
        return $class->SUPER::definition($definition);
}


#-------------------------------------------------------------------

sub duplicate {
	my $self = shift;
	my $newAsset = $self->SUPER::duplicate(shift);
	my $newStorage = $self->getStorageLocation->copy;
	$newAsset->update({storageId=>$newStorage->getId});
	return $newAsset;
}


#-------------------------------------------------------------------
sub getBox {
	my $self = shift;
	my $var = {};
       	return $self->processTemplate($var,"PBtmpl0000000000000003");
}

#-------------------------------------------------------------------

=head2 getEditForm ()

Returns the TabForm object that will be used in generating the edit page for this asset.

=cut

sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm();
	if ($self->get("filename") ne "") {
		$tabform->getTab("properties")->readOnly(
			-label=>WebGUI::International::get('current file', 'Asset_File'),
			-hoverHelp=>WebGUI::International::get('current file description', 'Asset_File'),
			-value=>'<a href="'.$self->getFileUrl.'"><img src="'.$self->getFileIconUrl.'" alt="'.$self->get("filename").'" border="0" align="middle" /> '.$self->get("filename").'</a>'
			);
		
	}
        $tabform->getTab("properties")->file(
		-label=>WebGUI::International::get('new file', 'Asset_File'),
		-hoverHelp=>WebGUI::International::get('new file description', 'Asset_File'),
               	);
	return $tabform;
}


#-------------------------------------------------------------------
sub getFileUrl {
	my $self = shift;
	return $self->getStorageLocation->getUrl($self->get("filename"));
}


#-------------------------------------------------------------------
sub getFileIconUrl {
	my $self = shift;
	return $self->getStorageLocation->getFileIconUrl($self->get("filename"));
}



#-------------------------------------------------------------------
sub getIcon {
	my $self = shift;
	my $small = shift;
	if ($small && ref($self) eq '') {
		return $session{config}{extrasURL}.'/assets/small/file.gif';
	} elsif ($small) {
		return $self->getFileIconUrl;	
	}
	return $session{config}{extrasURL}.'/assets/file.gif';
}


#-------------------------------------------------------------------
sub getStorageLocation {
	my $self = shift;
	unless (exists $self->{_storageLocation}) {
		if ($self->get("storageId") eq "") {
			$self->{_storageLocation} = WebGUI::Storage->create;
			$self->update({storageId=>$self->{_storageLocation}->getId});
		} else {
			$self->{_storageLocation} = WebGUI::Storage->get($self->get("storageId"));
		}
	}
	return $self->{_storageLocation};
}


#-------------------------------------------------------------------
sub processPropertiesFromFormPost {
	my $self = shift;
	$self->SUPER::processPropertiesFromFormPost;
	my $storage = $self->getStorageLocation;
	delete $self->{_storageLocation};
	my $filename = $storage->addFileFromFormPost("file");
	if (defined $filename) {
		my %data;
		$data{filename} = $filename;
		$data{storageId} = $storage->getId;
		$data{title} = $filename unless ($session{form}{title});
		$data{menuTitle} = $filename unless ($session{form}{menuTitle});
		$data{url} = $self->getParent->get('url').'/'.$filename unless ($session{form}{url});
		$self->update(\%data);
	}
}


#-------------------------------------------------------------------

sub purge {
	my $self = shift;
	my $sth = WebGUI::SQL->read("select storageId from FileAsset where assetId=".quote($self->getId));
	while (my ($storageId) = $sth->array) {
		WebGUI::Storage->get($storageId)->delete;
	}
	$sth->finish;
	return $self->SUPER::purge;
}

#-------------------------------------------------------------------

sub purgeRevision {
	my $self = shift;
	$self->getStorageLocation->delete;
	return $self->SUPER::purgeRevision;
}

#-------------------------------------------------------------------
sub setSize {
	my $self = shift;
	my $fileSize = shift || 0;
	my $storage = $self->getStorageLocation;
	foreach my $file (@{$storage->getFiles}) {
		$fileSize += $storage->getFileSize($file);
	}
	$self->SUPER::setSize($fileSize);
}

#-------------------------------------------------------------------

=head2 update

We override the update method from WebGUI::Asset in order to handle file system privileges.

=cut

sub update {
        my $self = shift;
        my %before = (
                owner => $self->get("ownerUserId"),
                view => $self->get("groupIdView"),
                edit => $self->get("groupIdEdit")
                );
        $self->SUPER::update(@_);
        if ($self->get("ownerUserId") ne $before{owner} || $self->get("groupIdEdit") ne $before{edit} || $self->get("groupIdView") ne $before{view}) {
                $self->getStorageLocation->setPrivileges($self->get("ownerUserId"),$self->get("groupIdView"),$self->get("groupIdEdit"));
        }
}

#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my %var = %{$self->get};
	$var{controls} = $self->getToolbar;
	$var{fileUrl} = $self->getFileUrl;
	$var{fileIcon} = $self->getFileIconUrl;
	return $self->processTemplate(\%var,$self->getValue("templateId"));
}


#-------------------------------------------------------------------
sub www_edit {
        my $self = shift;
        return WebGUI::Privilege::insufficient() unless $self->canEdit;
	my $tabform = $self->getEditForm;
	$tabform->getTab("display")->template(
		-value=>$self->getValue("templateId"),
		-hoverHelp=>WebGUI::International::get('file template description','Asset_Image'),
		-namespace=>"FileAsset"
		);
        $self->getAdminConsole->setHelp("file add/edit", "Asset_File");
        return $self->getAdminConsole->render($tabform->print,"Edit File");
}


sub www_view {
	my $self = shift;
	return WebGUI::Privilege::noAccess() unless $self->canView;
	if ($session{var}{adminOn}) {
		return $self->getContainer->www_view;
	}
	WebGUI::HTTP::setRedirect($self->getFileUrl);
	return "";
}


1;

