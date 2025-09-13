#!/usr/bin/perl

use warnings;
use strict;

use Net::DBus;
use Net::DBus::Reactor;

STDOUT->autoflush(1);

my $bus = Net::DBus->session;

# Prepare to query the org.kde.TabletMode setting
my $portal = $bus->get_service('org.freedesktop.portal.Desktop');
my $settings = $portal->get_object('/org/freedesktop/portal/desktop', 'org.freedesktop.portal.Settings');
sub tablet_mode { $settings->ReadOne('org.kde.TabletMode', 'enabled'); }

# Prepare to set the virtual keyboard state
# This object appears to be accessible from both org.kde.KWin and org.freedesktop.a11y.Manager
my $vkbd_svc = $bus->get_service('org.kde.KWin');
my $vkbd = $vkbd_svc->get_object('/VirtualKeyboard', 'org.freedesktop.DBus.Properties');
sub vkbd_get { $vkbd->Get('org.kde.kwin.VirtualKeyboard', 'enabled'); }
sub vkbd_enable { $vkbd->Set('org.kde.kwin.VirtualKeyboard', 'enabled', 1); }
sub vkbd_disable { $vkbd->Set('org.kde.kwin.VirtualKeyboard', 'enabled', 0); }

# Check and correct the initial state
my $start_mode = tablet_mode;
my $start_state = vkbd_get;
printf "vkbd_toggle.pl started.  Tablet mode state is %s. Virtual Keyboard state is %s\n", ($start_mode ? 'Enabled' : 'Disabled'), ($start_state ? 'Enabled' : 'Disabled');
if($start_state != $start_mode)
{
	if($start_mode){ vkbd_enable; print "Startup - enabling virtual keyboard\n"; }
	else{ vkbd_disable; print "Startup - diabling virtual keyboard\n"; }
}

# Callback signal handler for mode changes
sub handler
{
	my @args = @_;
	if($args[0] eq 'org.kde.TabletMode' and $args[1] eq 'enabled')
	{
		if($args[2])
		{
			# Tablet Mode
			print "Entered tablet mode - enabling virtual keyboard\n";
			vkbd_enable;
		}
		else
		{
			# Laptop Mode
			print "Exited tablet mode - disabling virtual keyboard\n";
			vkbd_disable;
		}
	}
};

# Attach the signal handler
my $sig = $settings->connect_to_signal('SettingChanged', \&handler);
unless($sig)
{
	die("Failed to attach signal handler.\n");
}

# Enter mainloop
my $reactor = Net::DBus::Reactor->main();
$reactor->run();

