package Template::Plugin::XSLT;
use strict;
use warnings;
use base 'Template::Plugin::Filter';
our $VERSION = '1.0';
use XML::LibXSLT;
use XML::LibXML;

sub init {
    my $self = shift;
    my $file = $self->{ _ARGS }->[0]
       or return $self->error('No filename specified!');

    $self->{ parser } = XML::LibXML->new();
    $self->{ XSLT } = XML::LibXSLT->new();
    my $xml;
    eval {
        $xml = $self->{ parser }->parse_file($file);
    };
    return $self->error("Stylesheet parsing error: $@") if $@;
    return $self->error("Stylesheet parsing errored") unless $xml;

    eval { 
        $self->{ stylesheet } = 
            $self->{ XSLT }->parse_stylesheet( $xml );
    };
    return $self->error("Stylesheet not valid XSL: $@") if $@;
    return $self->error("Stylesheet parsing errored") unless $self->{stylesheet};

    return $self;
}

sub filter {
    my ($self, $text) = @_;
    my $xml;
    eval {
        $xml = $self->{ parser }->parse_string($text);
    };
    return $self->error("XML parsing error: $@") if $@;
    return $self->error("XML parsing errored") unless $xml;

    return $self->{ stylesheet}->output_string(
        $self->{ stylesheet }->transform( $xml )
    );
}

# Preloaded methods go here.

1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Template::Plugin::XSLT - Transform XML fragments into something else

=head1 SYNOPSIS

    [% USE transform = XSLT("stylesheet.xsl"); %]
    ...
    [% foo.as_xml | $transform %]

=head1 DESCRIPTION

This plugin for the Template Toolkit uses C<XML::LibXSLT> to transform
a chunk of XML through a filter. If the stylesheet is not valid, or if
the XML does not parse, an exception will be raised.

=head1 AUTHOR

Simon Cozens, C<simon@cpan.org>

=head1 SEE ALSO

L<Template>, L<XML::LibXSLT>.

=cut
