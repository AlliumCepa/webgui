insert into webguiVersion values ('5.2.3','upgrade',unix_timestamp());
delete from template where templateId=2 and namespace='Item';
INSERT INTO template VALUES (2,'Item w/pop-up Links','<tmpl_if displaytitle>\r\n   <tmpl_if linkurl>\r\n       <a href=\"<tmpl_var linkurl>\" target=\"_blank\">\r\n    </tmpl_if>\r\n     <span class=\"itemTitle\"><tmpl_var title></span>\r\n   <tmpl_if linkurl>\r\n      </a>\r\n    </tmpl_if>\r\n</tmpl_if>\r\n\r\n<tmpl_if attachment.name>\r\n   <tmpl_if displaytitle> - </tmpl_if>\r\n   <a href=\"<tmpl_var attachment.url>\" target=\"_blank\"><img src=\"<tmpl_var attachment.Icon>\" border=\"0\" alt=\"<tmpl_var attachment.name>\" width=\"16\" height=\"16\" border=\"0\" align=\"middle\" /></a>\r\n</tmpl_if>\r\n\r\n<tmpl_if description>\r\n  - <tmpl_var description>\r\n</tmpl_if>','Item');
delete from international where languageId=2 and namespace='Survey' and internationalId=66;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (66,2,'Survey','Geantwortet', 1049146849);
delete from international where languageId=2 and namespace='Survey' and internationalId=53;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (53,2,'Survey','Geantwortet', 1049146653);
delete from international where languageId=2 and namespace='Survey' and internationalId=69;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (69,2,'Survey','Antworten dieses Benutzers l�schen.', 1049146361);
delete from international where languageId=2 and namespace='Survey' and internationalId=70;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (70,2,'Survey','Individuelle Antworten', 1049146347);
delete from international where languageId=2 and namespace='Survey' and internationalId=72;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (72,2,'Survey','Sind Sie sicher, dass Sie die Antworten dieses Benutzers l�schen m�chten?', 1049146334);
delete from international where languageId=2 and namespace='Survey' and internationalId=55;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (55,2,'Survey','Antworten anschauen.', 1049146220);
delete from international where languageId=2 and namespace='Survey' and internationalId=74;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (74,2,'Survey','Sind Sie sicher, dass Sie alle Antworten l�schen m�chten?', 1049146085);
delete from international where languageId=2 and namespace='Survey' and internationalId=73;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (73,2,'Survey','Alle Antworten l�schen.', 1049146069);
delete from international where languageId=2 and namespace='WebGUI' and internationalId=891;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (891,2,'WebGUI','Nur Makros blockieren.', 1049099974);
delete from international where languageId=2 and namespace='WebGUI' and internationalId=526;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (526,2,'WebGUI','JavaScript entfernen und blockiere Makros.', 1049099918);
alter table MailForm_field change validation validation varchar(255) not null default 'none';
update MailForm_field set validation='none' where validation='';
delete from international where languageId=2 and namespace='WobjectProxy' and internationalId=6;
insert into international (internationalId,languageId,namespace,message,lastUpdated) values (6,2,'WobjectProxy','Mit dem Wobject Proxy k�nnen Sie ein bereits vorhandenes Wobject auf einer anderen Seite spiegeln, das heisst, das ein und das selbe Wobject auf mehreren Seiten vorkommen kann.<br><br>\r\n\r\n<b>Wobject To Proxy</b><br>\r\nW�hlen Sie ein Wobject aus Ihrem System aus, dass Sie als Proxy Element nutzen m�chten. Die Auswahlbox hat das Format \"Seiten Titel/Wobject Name (Wobject ID), so dass Sie schnell und direkt das Wobject finden k�nnen, dass Sie ben�tigen.', 1049548414);


