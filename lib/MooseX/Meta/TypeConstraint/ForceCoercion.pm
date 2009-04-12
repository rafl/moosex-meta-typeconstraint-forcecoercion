package MooseX::Meta::TypeConstraint::ForceCoercion;

use Moose;
use namespace::autoclean;

has _type_constraint => (
    is       => 'ro',
    isa      => 'Moose::Meta::TypeConstraint',
    init_arg => 'type_constraint',
    required => 1,
    handles  => qr/^(?!(?:validate|check)$)/,
);

sub check {
    my ($self, $value) = @_;
    my $coerced = $self->_type_constraint->coerce($value);
    return undef if $coerced == $value;
    return $self->_type_constraint->check($coerced);
}

sub validate {
    my ($self, $value) = @_;
    my $coerced = $self->_type_constraint->coerce($value);
    return 'coercion failed' if $coerced == $value;
    return $self->_type_constraint->valudate($coerced);
}

my $meta = __PACKAGE__->meta;

for my $meth (qw/isa can meta/) {
    my $orig = __PACKAGE__->can($meth);
    $meta->add_method($meth => sub {
        my ($self) = shift;
        return $self->$orig(@_) unless blessed $self;
        return $self->_type_constraint->$meth(@_);
    });
}

$meta->make_immutable;

1;
