use strict;
use warnings;
use CLI::Startup;
use Devel::NYTProf::Complexity;

main();

sub main {
    my $self = shift;

    my $opts = _setup();
    my $prepared_data = Devel::NYTProf::Complexity->run($opts);
    Devel::NYTProf::Complexity->display($prepared_data);
}

sub _setup {
    my $self = shift;

    my $app = CLI::Startup->new({
        'filename=s' => 'the filename of your nytprof.out file',
        'verbose' => 'verbose output flag'
    });
    
    $app->init;
    my $opts = $app->get_options;

    return $opts;
}
