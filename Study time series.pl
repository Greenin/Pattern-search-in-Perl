# Study time series for the subject Econometrics

# Copyright (c) 2015 Oscar Parrilla

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

#!c:\strawberry\perl\bin\perl.exe -w


# use encoding 'utf8';
use strict;
# use HTML::Entities;
use DBI;
use LWP::UserAgent;
use HTTP::Request;

use warnings;

##########################################################################################################
## 									         Constantes							    					##
##########################################################################################################

# use constant minimun_repetition_num => 7;
#use constant success_probability => 60; # 85, 59,75

# use constant short_percent_c => 0.005;  #0.05,0.01, 0.07, 0.005, 
# use constant long_percent_c => 0.05;  #0.2,0.1,0.4,0.15

# use constant sleep_seconds => 3;  # Second to sleep

# use constant initial_year => 2017; 
# use constant initial_month => "Jan"; # Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec, etc

#use constant num_of_days_to_check => 8;

#use constant sucess_probability_file => "C:/Users/file_of_2_impulses_research_ result.txt";
# use constant sucess_probability_file => "E:/file_of_2_impulses_research_ result.txt";

#use constant file_with_checkup => "C:/Users/file_of_2_impulse_research_ result_summary.txt";
# use constant file_with_checkup => "E:/file_of_2_impulse_research_ result_summary.txt";

##########################################################################################################
## 									         Variables							    					##
##########################################################################################################

my ($sec,$min,$aux_hour,$mday,$mon,$aux_year,$wday,$yday,$isdst) ;

my $database;
my $host;
my $user;
my $password;
my $connection;
my $query_handle;
my $delete;


my $short_percent_c;
my $long_percent_c;
my $sleep_seconds;
my $initial_year;
my $initial_month;
my $sucess_probability_file;
my $file_with_checkup;


my @day_array;
my $day_ind;
my @time_series;
my $ind;
my $finish;
my $max_null_day_num;
my $not_impulse_number;


my $time_serie_file_name;
#my $sucess_probability_file;

my $number_of_days_to_check;
#my $num_of_days_to_check;
my $success_probability;

my $start_success_probability;
my $final_success_probability;
my $start_num_of_days_to_check;
my $final_num_of_days_to_check;


my $time_serie;
my $initial_day;
my $year;
my $month;
my $day; 
my $query;
my $row;
my $min_hour;
my $min_minute;
my $max_hour;
my $max_minute;
my @period_array;
my $j;
my $minute_period;
my $positive_minimun_percent;
my $negative_minimun_percent;
my $hour;
my $minute;
my $last_minute;
my $last_hour;
my $continue ;
my $increment_num;
my $decrement_num;
my $null_day_counter;
my $day_num;
my $be_num;
my $h_percent;
my $l_percent;
my $rule;
# my $increment;
# my $decrement; 
# my $flat;
my $time_serie_percent;
my @checked_days;
my $previous_day_found;

my $total_number_of_fails;
my $total_number_of_success;
my $total_number_of_checkups;
my $total_number_of_no_attemps;

my $is_error;

my $highAverage;
my $maxLow;
my $highStdDev;



##########################################################################################################
## 											 Funciones													##
##########################################################################################################

sub check_day
{	
	my($f_time_serie, $f_minute, $f_hour, $f_day, $f_month, $f_year, $f_minute_period) = @_;
	
	my $open;
	my $high;
	my $low;
	my $low_percent;
	my $high_percent;
	my $first_minute_long;
	my $first_minute_open;
	my $first_minute_low;
	my $first_minute_high;
	# my $second_minute_short;
	my $second_minute_long;
	my $dir;
	my $max;
	my $min;
	my $long_percent;

	
	$dir = "null";
	
	
	$first_minute_open = undef;
	# $high =undef;
	# $low = undef;
	
	$query = "SELECT open,high,low from TB_MINUTE WHERE  time_serie = '$f_time_serie' AND hour_minute_f= $f_minute AND day_hour_f= $f_hour AND day=$f_day AND  month='$f_month' AND  year=$f_year";
	$query_handle =$connection->prepare($query);
	$query_handle->execute();
	$row = $query_handle->fetchrow_hashref();
	$first_minute_open = $row->{'open'};
	$first_minute_high = $row->{'high'};
	$first_minute_low = $row->{'low'};
	
	if (!defined($first_minute_open))
	{
		return (0,0,0) ;
	}	
	# print "\nfirst_minute_open, first_minute_low, first_minute_high: $first_minute_open, $first_minute_low, $first_minute_high\n";###############################################
	$low_percent = ((abs($first_minute_open - $first_minute_low))/$first_minute_open)*100;
	$high_percent = ((abs($first_minute_open - $first_minute_high))/$first_minute_open)*100;
	
	if ($low_percent<$short_percent_c || $high_percent<$short_percent_c )  
	{
				# $first_minute = 1;
				# $first_minute_low = $low;
				# $first_minute_high = $high;
				if ($first_minute_low<$first_minute_high)
				{
					$first_minute_long = $first_minute_high;
				}
				else
				{
					$first_minute_long = $first_minute_low;
				}
	 }
	 else
	 {
		return ($low_percent,$long_percent,0);
		# return (0,0,0) ;
	 }




	($f_hour, $f_minute) = next_time($f_hour, $f_minute,1);

	
	# } # for	
	
	$open = undef;
	
	$query = "SELECT open,high,low from TB_MINUTE WHERE  time_serie = '$f_time_serie' AND hour_minute_f= $f_minute AND day_hour_f= $f_hour AND day=$f_day AND  month='$f_month' AND  year=$f_year";
	$query_handle =$connection->prepare($query);
	$query_handle->execute();
	$row = $query_handle->fetchrow_hashref();
	$open = $row->{'open'};
	$high = $row->{'high'};
	$low = $row->{'low'};
	
	if (!defined($open))
	{
		return (0,0,0) ;
	}	

	
	if ($low>$first_minute_low)
	{
		$dir = "i";
		$second_minute_long = $high;
		if ($low_percent>$short_percent_c )
		{
			# return (0,0,0);
			return ($low_percent,$long_percent,0);
		}		
	}
	elsif ($high<$first_minute_high)
	{
		$dir = "d";
		$second_minute_long = $low;
		if ($high_percent>$short_percent_c )
		{
			# return (0,0,0);
			return ($low_percent,$long_percent,0);
		}
	 }
	 else
	 {
		# return (0,0,0);
		return ($low_percent,$long_percent,0);
	 }
	
	if ($dir eq "i")
	{
		$max = $first_minute_long;
		if ($first_minute_long<$second_minute_long)
		{
			$max =$second_minute_long;
		}

		$long_percent = ((abs($first_minute_open - $max))/$first_minute_open)*100;

		if ($long_percent>$long_percent_c)  
		{		
				
			return ($low_percent,$long_percent,1);
		}

	}
	
	if ($dir eq "d")
	{
		$min = $first_minute_long;
		if ($first_minute_long>$second_minute_long)
		{
			$min =$second_minute_long;
		}

		$long_percent = ((abs($first_minute_open - $min))/$first_minute_open)*100;

		if ($long_percent>$long_percent_c)  
		{
						
			return ($high_percent,$long_percent,1);
		}

	}	
	
	# return (0,0,0);
	return ($low_percent,$long_percent,0);
		
}


sub next_day 
{	
	my($f_time_serie, $f_minute, $f_hour, $f_day, $f_month, $f_year) = @_;

	my $timestamp;
	my $prev_day;
	my $prev_month;
	my $prev_year;
	
	$timestamp = undef;
	$query = "SELECT timestamp from TB_MINUTE WHERE  time_serie = '$f_time_serie' AND hour_minute_f= $f_minute AND day_hour_f= $f_hour AND day=$f_day AND  month='$f_month' AND  year=$f_year";
	$query_handle =$connection->prepare($query);
	$query_handle->execute();
	$row = $query_handle->fetchrow_hashref();
	$timestamp = $row->{'timestamp'};
	
	if (!defined($timestamp))
	{
		return ($f_day, $f_month, $f_year, 0) ;
	}	
	
	$query = "SELECT MIN(timestamp) AS max_timestamp from TB_MINUTE WHERE  time_serie = '$f_time_serie' AND timestamp > $timestamp AND day <>$f_day";
	$query_handle =$connection->prepare($query);
	$query_handle->execute();
	$row = $query_handle->fetchrow_hashref();
	$timestamp = $row->{'max_timestamp'};
	
	if (!defined($timestamp))
	{
		return ($f_day, $f_month, $f_year,0) ;
	}	
	
	$prev_day = undef;
	$prev_month = undef;
	$prev_year = undef;	
	$query = "SELECT day, month,year from TB_MINUTE WHERE  time_serie = '$f_time_serie' AND timestamp = $timestamp";
	$query_handle =$connection->prepare($query);
	$query_handle->execute();
	$row = $query_handle->fetchrow_hashref();
	$prev_day = $row->{'day'};
	$prev_month = $row->{'month'};
	$prev_year = $row->{'year'};	
	
	if (!defined($prev_day))
	{
		return ($f_day, $f_month, $f_year,0) ;
	}	
	
	return ($prev_day, $prev_month, $prev_year,1);	
}


sub next_time 
{	
	my ($f_hour,$f_minute,$minute_addition) = @_;
	
	my $div60;
	my $remainder60;
	
	$div60 = int(($minute+$minute_addition) / 60);
	$remainder60 = ($minute+$minute_addition) % 60;
	
	if ($div60 >0)
	{
		return ($f_hour+$div60,$remainder60);
	}
	else
	{
		return ($f_hour, $f_minute+$minute_addition);
	}
}



sub checked_day_trend 
{	
	my ($f_change) = @_;
	
	my $last_day_i;
	my $f_open;
	my $f_next_open;
	my $rem;
	
	$last_day_i = scalar(@checked_days)-1;	

	$query = "SELECT open from TB_MINUTE WHERE  time_serie = '$checked_days[0][0]' AND hour_minute_f= $checked_days[0][2] AND day_hour_f= $checked_days[0][1] AND day= $checked_days[0][3] AND  month='$checked_days[0][4]' AND  year= $checked_days[0][5]";
	$query_handle =$connection->prepare($query);
	$query_handle->execute();
	$row = $query_handle->fetchrow_hashref();
	$f_open = $row->{'open'};		
	if (!defined($f_open))
	{
		return 1 ;
	}
		
	$query = "SELECT open from TB_MINUTE WHERE  time_serie = '$checked_days[$last_day_i][0]' AND hour_minute_f= $checked_days[$last_day_i][2] AND day_hour_f= $checked_days[$last_day_i][1] AND day= $checked_days[$last_day_i][3] AND  month='$checked_days[$last_day_i][4]' AND  year= $checked_days[$last_day_i][5]";
	$query_handle =$connection->prepare($query);
	$query_handle->execute();
	$row = $query_handle->fetchrow_hashref();
	$f_next_open = $row->{'open'};	
	if (!defined($f_next_open))
	{
		return 1 ;
	}	
	
	$rem = $f_next_open - $f_open;
	
	if ($rem<0 && $f_change eq "i")
	{
		return 0;
	}
	elsif ($rem>0 && $f_change eq "d")
	{
		return 0;		
	}
	else
	{
		return 1;
	}
	
}


sub check_3_next_days 
{	
	# my ($change) = @_;
	
	my $last_day_ind;
	my $day2;
	my $month2;
	my $year2;
	my $next_day_found;
	my $f_time_serie_percent;
	# my $f_be_num;
	my $f_rule;
	my $lo_percent;
	my $hi_percent;
	
	#my $file_with_checkup;
	
	
	#$file_with_checkup = "C:/Users/file_of_2_impulse_research_ result_summary.txt";
	
	open (FicheroSalida3,">>".$file_with_checkup) || die "ERROR: No se pudo abrir el fichero ".$file_with_checkup."\n";
	if ($checked_days[0][0] ne "null")	{ print FicheroSalida3 "$checked_days[0][0]\n";print FicheroSalida3 "$minute_period minutes, ";print FicheroSalida3 "$checked_days[0][1]:$checked_days[0][2]\n";}
	elsif ($checked_days[1][0] ne "null")	 {	print FicheroSalida3 "$checked_days[1][0]\n";print FicheroSalida3 "$minute_period minutes, ";print FicheroSalida3 "$checked_days[1][1]:$checked_days[1][2]\n";}
	elsif ($checked_days[2][0] ne "null")	 {	print FicheroSalida3 "$checked_days[2][0]\n";print FicheroSalida3 "$minute_period minutes, ";print FicheroSalida3 "$checked_days[2][1]:$checked_days[2][2]\n";}
	else	{	print FicheroSalida3 "$checked_days[3][0]\n";print FicheroSalida3 "$minute_period minutes, ";print FicheroSalida3 "$checked_days[3][1]:$checked_days[3][2]\n";}	
	# print FicheroSalida3 "$checked_days[0][0], ";

	
	$last_day_ind = scalar(@checked_days)-1;
	if ($checked_days[$last_day_ind][0] eq "null") {print FicheroSalida3 "Day not found\n**********************\n";close(FicheroSalida3);return;}
	#
	($day2, $month2, $year2, $next_day_found) = next_day($checked_days[$last_day_ind][0], $checked_days[$last_day_ind][2], $checked_days[$last_day_ind][1], $checked_days[$last_day_ind][3], $checked_days[$last_day_ind][4], $checked_days[$last_day_ind][5]);
	
	if (!$next_day_found) {print FicheroSalida3 "Day not found\n*******************\n";close(FicheroSalida3);return;}
	
	# ($f_be_num,$f_time_serie_percent) = check_day($checked_days[$last_day_ind][0], $checked_days[$last_day_ind][2], $checked_days[$last_day_ind][1], $day2, $month2, $year2,$minute_period);
	($lo_percent,$hi_percent,$f_rule) = check_day($checked_days[$last_day_ind][0], $checked_days[$last_day_ind][2], $checked_days[$last_day_ind][1], $day2, $month2, $year2,$minute_period); 
	if ($f_rule>0) 
	{		
		print FicheroSalida3 "SUCCESS on first day, ";	
		$total_number_of_success++;
		$total_number_of_checkups++;
		print FicheroSalida3 "Sucess ratio: $total_number_of_success of $total_number_of_checkups , sucess percent: ".(($total_number_of_success/$total_number_of_checkups)*100)." %\n";
		print FicheroSalida3 "$day2 $month2 $year2, $lo_percent ,$hi_percent\n";	
	
	}
	else
	{
		print FicheroSalida3 "Failure: $day2 $month2 $year2, $lo_percent ,$hi_percent\n";	
		($day2, $month2, $year2, $next_day_found) = next_day($checked_days[$last_day_ind][0], $checked_days[$last_day_ind][2], $checked_days[$last_day_ind][1],$day2, $month2, $year2);

		if (!$next_day_found){print FicheroSalida3 "Day not found\n*********************************\n";close(FicheroSalida3);return;}
		
		
		($lo_percent,$hi_percent,$f_rule) = check_day($checked_days[$last_day_ind][0], $checked_days[$last_day_ind][2], $checked_days[$last_day_ind][1], $day2, $month2, $year2,$minute_period); 
		if ($f_rule>0) 
		{			
		# {
			print FicheroSalida3 "SUCCESS on second day, ";	
			$total_number_of_success++;
			$total_number_of_checkups++;
			print FicheroSalida3 "Sucess ratio: $total_number_of_success of $total_number_of_checkups , sucess percent: ".(($total_number_of_success/$total_number_of_checkups)*100)." %\n";	
			print FicheroSalida3 "$day2 $month2 $year2, $lo_percent ,$hi_percent\n";	
		}
		else
		{
			print FicheroSalida3 "Failure: $day2 $month2 $year2, $lo_percent ,$hi_percent\n";	
			($day2, $month2, $year2, $next_day_found) = next_day($checked_days[$last_day_ind][0], $checked_days[$last_day_ind][2], $checked_days[$last_day_ind][1],$day2, $month2, $year2);
			
			if (!$next_day_found){print FicheroSalida3 "Day not found\n***********************************************************************\n";close(FicheroSalida3);return;}
			
			
			($lo_percent,$hi_percent,$f_rule) = check_day($checked_days[$last_day_ind][0], $checked_days[$last_day_ind][2], $checked_days[$last_day_ind][1], $day2, $month2, $year2,$minute_period); 
			if ($f_rule>0) 
			{					

				print FicheroSalida3 "SUCCESS on third day, ";	
				$total_number_of_success++;
				$total_number_of_checkups++;
				print FicheroSalida3 "Sucess ratio: $total_number_of_success of $total_number_of_checkups , sucess percent: ".(($total_number_of_success/$total_number_of_checkups)*100)." %\n";
				print FicheroSalida3 "$day2 $month2 $year2, $lo_percent ,$hi_percent\n";		
			}
			else
			{
				print FicheroSalida3 "Failure: $day2 $month2 $year2, $lo_percent ,$hi_percent\n";	
				($day2, $month2, $year2, $next_day_found) = next_day($checked_days[$last_day_ind][0], $checked_days[$last_day_ind][2], $checked_days[$last_day_ind][1],$day2, $month2, $year2);
					
				if (!$next_day_found){print FicheroSalida3 "Day not found\n***********************************************************************\n";close(FicheroSalida3);return;}
						
				($lo_percent,$hi_percent,$f_rule) = check_day($checked_days[$last_day_ind][0], $checked_days[$last_day_ind][2], $checked_days[$last_day_ind][1], $day2, $month2, $year2,$minute_period); 
				if ($f_rule>0) 
				{					
				
					print FicheroSalida3 "SUCCESS on fourth day, ";	
					$total_number_of_success++;
					$total_number_of_checkups++;
					print FicheroSalida3 "Sucess ratio: $total_number_of_success of $total_number_of_checkups , sucess percent: ".(($total_number_of_success/$total_number_of_checkups)*100)." %\n";
					print FicheroSalida3 "$day2 $month2 $year2, $lo_percent ,$hi_percent\n";	

				}
				else
				{
					print FicheroSalida3 "Failure: $day2 $month2 $year2, $lo_percent ,$hi_percent\n";	
					$total_number_of_fails++;
					$total_number_of_checkups++;
					print FicheroSalida3 "Failure ratio: $total_number_of_fails of $total_number_of_checkups , Failure percent: ".(($total_number_of_fails/$total_number_of_checkups)*100)." %\n";
					print FicheroSalida3 "XXXX FAILURE on all days\n";								

				}			
			}		
		}
	}	
	
	print FicheroSalida3 "***********************************************************************\n";
	close (FicheroSalida3);
	
			
}
	




	
sub check_1_next_days 
{	
	# my ($change) = @_;
	
	my $last_day_ind;
	my $day2;
	my $month2;
	my $year2;
	my $next_day_found;
	my $f_time_serie_percent;
	# my $f_be_num;
	my $f_rule;
	my $lo_percent;
	my $hi_percent;
	my $last_day;	
	#my $file_with_checkup;	
	
	#$file_with_checkup = "C:/Users/file_of_2_impulse_research_ result_summary.txt";
	
	open (FicheroSalida3,">>".$file_with_checkup) || die "ERROR: No se pudo abrir el fichero ".$file_with_checkup."\n";
	print FicheroSalida3 "Success probability: $success_probability\n";
	print FicheroSalida3 "Number of days to ckeck: $number_of_days_to_check\n";
	if ($checked_days[0][0] ne "null")	{ print FicheroSalida3 "$checked_days[0][0]\n";print FicheroSalida3 "$minute_period minutes, ";print FicheroSalida3 "$checked_days[0][1]:$checked_days[0][2]\n";}
	elsif ($checked_days[1][0] ne "null")	 {	print FicheroSalida3 "$checked_days[1][0]\n";print FicheroSalida3 "$minute_period minutes, ";print FicheroSalida3 "$checked_days[1][1]:$checked_days[1][2]\n";}
	elsif ($checked_days[2][0] ne "null")	 {	print FicheroSalida3 "$checked_days[2][0]\n";print FicheroSalida3 "$minute_period minutes, ";print FicheroSalida3 "$checked_days[2][1]:$checked_days[2][2]\n";}
	else	{	print FicheroSalida3 "$checked_days[3][0]\n";print FicheroSalida3 "$minute_period minutes, ";print FicheroSalida3 "$checked_days[3][1]:$checked_days[3][2]\n";}
	
	$last_day_ind = scalar(@checked_days)-1;
	if ($checked_days[$last_day_ind][0] ne "null")
	{
		$last_day ="$checked_days[$last_day_ind][3] $checked_days[$last_day_ind][4] $checked_days[$last_day_ind][5]";
	}
	else
	{
		if ($last_day_ind>0)
		{
			$last_day_ind--;
			if ($checked_days[$last_day_ind][0] ne "null")
			{
				$last_day ="$checked_days[$last_day_ind][3] $checked_days[$last_day_ind][4] $checked_days[$last_day_ind][5]";
			}
			else
			{
				if ($last_day_ind>0)
				{
					$last_day_ind--;
					if ($checked_days[$last_day_ind][0] ne "null")
					{
						$last_day ="$checked_days[$last_day_ind][3] $checked_days[$last_day_ind][4] $checked_days[$last_day_ind][5]";
					}
					else
					{
						if ($last_day_ind>0)
						{
							$last_day_ind--;
							if ($checked_days[$last_day_ind][0] ne "null")
							{
								$last_day ="$checked_days[$last_day_ind][3] $checked_days[$last_day_ind][4] $checked_days[$last_day_ind][5]";
							}
							else
							{
								$last_day ="Day not found";
							}			
						}
					}
				}			
			}
		}	
	}
	print FicheroSalida3 "Last day: $last_day\n";
	print FicheroSalida3 ">> High average: $highAverage\n";
	print FicheroSalida3 ">> Maximun low: $maxLow\n";
	print FicheroSalida3 ">> High standard deviation: $highStdDev\n";
	print FicheroSalida3 ">> High avg - High std dev: ".($highAverage-$highStdDev)."\n";
	# print FicheroSalida3 "$checked_days[0][0], ";
	# print FicheroSalida3 "$minute_period minutes, ";
	# print FicheroSalida3 "$checked_days[0][1]:$checked_days[0][2]\n";	
	
	$last_day_ind = scalar(@checked_days)-1;
	if ($checked_days[$last_day_ind][0] eq "null")
	{	
		if ($last_day_ind>0)
		{
			$last_day_ind--;
			
			if ($checked_days[$last_day_ind][0] eq "null")
			{
				if ($last_day_ind>0)
				{
					$last_day_ind--;
					
					if ($checked_days[$last_day_ind][0] eq "null")
					{	
						if ($last_day_ind>0)
						{
							$last_day_ind--;
				
							if ($checked_days[$last_day_ind][0] eq "null")
							{
								print FicheroSalida3 "Day not found in array\n********************************\n";
								close(FicheroSalida3);
								return;
							}
						}
					}
				}
			}
		}
	}
	($day2, $month2, $year2, $next_day_found) = next_day($checked_days[$last_day_ind][0], $checked_days[$last_day_ind][2], $checked_days[$last_day_ind][1], $checked_days[$last_day_ind][3], $checked_days[$last_day_ind][4], $checked_days[$last_day_ind][5]);
	
	if (!$next_day_found) {print FicheroSalida3 "Next day not found\n**********************************\n";close(FicheroSalida3);return;}
	
	($lo_percent,$hi_percent,$f_rule) = check_day($checked_days[$last_day_ind][0], $checked_days[$last_day_ind][2], $checked_days[$last_day_ind][1], $day2, $month2, $year2,$minute_period); 
	if ($f_rule>0) 
	{		
		print FicheroSalida3 "Success: $day2 $month2 $year2, $lo_percent ,$hi_percent\n";	
		$total_number_of_success++;
		$total_number_of_checkups++;
		print FicheroSalida3 "Sucess ratio: $total_number_of_success of $total_number_of_checkups , sucess percent: ".(($total_number_of_success/$total_number_of_checkups)*100)." %\n";
	}
	else
	{
		if ($hi_percent<$short_percent_c && $lo_percent<$short_percent_c)
		{
			print FicheroSalida3 "No attemp: $day2 $month2 $year2, $lo_percent ,$hi_percent\n";
			$total_number_of_checkups++;
			$total_number_of_no_attemps++;
			print FicheroSalida3 "No attemp ratio: $total_number_of_no_attemps of $total_number_of_checkups , No attemp percent: ".(($total_number_of_no_attemps/$total_number_of_checkups)*100)." %\n";		
		}
		else
		{
			print FicheroSalida3 "Failure: $day2 $month2 $year2, $lo_percent ,$hi_percent\n";	
			$total_number_of_fails++;
			$total_number_of_checkups++;
			print FicheroSalida3 "Failure ratio: $total_number_of_fails of $total_number_of_checkups , Failure percent: ".(($total_number_of_fails/$total_number_of_checkups)*100)." %\n";
		}
	}
	
	print FicheroSalida3 "***********************************************************************\n";
	close (FicheroSalida3);
			
}
	



sub show_investment 
{	
	# my ($change) = @_;
	
	my $day2;
	my $month2;
	my $year2;
	my $next_day_found;
	my $f_time_serie_percent;
	# my $f_be_num;
	my $f_rule;
	my $lo_percent;
	my $hi_percent;
	my $last_day_index;
	my $last_day;	
	
	#my $file_with_checkup;
	
	
	#$file_with_checkup = "C:/Users/file_of_2_impulse_research_ result_summary.txt";
	
	open (FicheroSalida3,">>".$file_with_checkup) || die "ERROR: No se pudo abrir el fichero ".$file_with_checkup."\n";
	if ($checked_days[0][0] ne "null")	{ print FicheroSalida3 "$checked_days[0][0]\n";print FicheroSalida3 "$minute_period minutes, ";print FicheroSalida3 "$checked_days[0][1]:$checked_days[0][2]\n";}
	elsif ($checked_days[1][0] ne "null")	 {	print FicheroSalida3 "$checked_days[1][0]\n";print FicheroSalida3 "$minute_period minutes, ";print FicheroSalida3 "$checked_days[1][1]:$checked_days[1][2]\n";}
	elsif ($checked_days[2][0] ne "null")	 {	print FicheroSalida3 "$checked_days[2][0]\n";print FicheroSalida3 "$minute_period minutes, ";print FicheroSalida3 "$checked_days[2][1]:$checked_days[2][2]\n";}
	else	{	print FicheroSalida3 "$checked_days[3][0]\n";print FicheroSalida3 "$minute_period minutes, ";print FicheroSalida3 "$checked_days[3][1]:$checked_days[3][2]\n";}	
	
	$last_day_index = scalar(@checked_days)-1;
	if ($checked_days[$last_day_index][0] ne "null")
	{
		$last_day ="$checked_days[$last_day_index][3] $checked_days[$last_day_index][4] $checked_days[$last_day_index][5]";
	}
	else
	{
		if ($last_day_index>0)
		{
			$last_day_index--;
			if ($checked_days[$last_day_index][0] ne "null")
			{
				$last_day ="$checked_days[$last_day_index][3] $checked_days[$last_day_index][4] $checked_days[$last_day_index][5]";
			}
			else
			{
				if ($last_day_index>0)
				{
					$last_day_index--;
					if ($checked_days[$last_day_index][0] ne "null")
					{
						$last_day ="$checked_days[$last_day_index][3] $checked_days[$last_day_index][4] $checked_days[$last_day_index][5]";
					}
					else
					{
						$last_day_index--;
						if ($last_day_index>0)
						{
							if ($checked_days[$last_day_index][0] ne "null")
							{
								$last_day ="$checked_days[$last_day_index][3] $checked_days[$last_day_index][4] $checked_days[$last_day_index][5]";
							}
							else
							{
								$last_day ="Last day not found in array";
							}			
						}
					}
				}			
			}
		}	
	}
	print FicheroSalida3 "Success probability: $success_probability\n";
	print FicheroSalida3 "Number of days to ckeck: $number_of_days_to_check\n";
	print FicheroSalida3 "Last day: $last_day\n";
	
	print FicheroSalida3 ">> High average: $highAverage\n";
	print FicheroSalida3 ">> Maximun low: $maxLow\n";
	print FicheroSalida3 ">> High standard deviation: $highStdDev\n";
	print FicheroSalida3 ">> High avg - High std dev: ".($highAverage-$highStdDev)."\n";
	# print FicheroSalida3 "$checked_days[0][0], ";
	# print FicheroSalida3 "$minute_period minutes, ";
	# print FicheroSalida3 "$checked_days[0][1]:$checked_days[0][2]\n";	
	
	print FicheroSalida3 "***********************************************************************\n";
	close (FicheroSalida3);
			
}	

	

sub check_day_array 
{	
	my (@f_checked_days) = @_;
	
	my $i;
	my $impulse_num;
	my $impulse_percent;
	# my $increment_num;
	# my $decrement_num ;
	# my $increment_percent;
	# my $decrement_percent;
	my $output_line;
	my $ch;
	my $sumOfHighNum;
	my $sumOfStandDesv;
	
	
	if (scalar(@f_checked_days)>=$number_of_days_to_check)
	{
	 if (($f_checked_days[scalar(@f_checked_days)-1][0] ne "null")||($f_checked_days[scalar(@f_checked_days)-2][0] ne "null")||($f_checked_days[scalar(@f_checked_days)-3][0] ne "null"))
	{	
	
	
	$impulse_num = 0;		
	for ($i =0; $i<scalar(@f_checked_days); $i++)
	{
		if ($f_checked_days[$i][0] ne "null")
		{		
				$impulse_num++;
		}
	}

	$impulse_percent = ($impulse_num/scalar(@f_checked_days))*100;
		
	# if ($increment_num>=minimun_repetition_num && $increment_percent> $success_probability)
	#if ($impulse_percent>= $success_probability && $impulse_num>6)
	if ($impulse_percent>= $success_probability)
	{	
		# $ch= "i";
		# if (!checked_day_trend($ch))
		# {
			print "\n>>>>>>>>>>>>>>PATTERN FOUND.\n";
			open (FicheroSalida,">>".$sucess_probability_file) || die "ERROR: No se pudo abrir el fichero ".$sucess_probability_file."\n";
			# print FicheroSalida "\nINCREMENT percent: $increment_percent %\n";
			print FicheroSalida "\n$impulse_num times of ".scalar(@f_checked_days)."\n";
			print FicheroSalida "Success probability: ".$success_probability."\n";
			print FicheroSalida "Number of days to check: ".$number_of_days_to_check."\n";
			if ($f_checked_days[0][0] ne "null")	{ print FicheroSalida "Time serie: $f_checked_days[0][0]\n";	}
			elsif ($f_checked_days[1][0] ne "null")	 {	print FicheroSalida "Time serie: $f_checked_days[1][0]\n";}
			elsif ($f_checked_days[2][0] ne "null")	 {	print FicheroSalida "Time serie: $f_checked_days[2][0]\n";}
			else	{	print FicheroSalida "Time serie: $f_checked_days[3][0]\n";	}
			# print FicheroSalida "Minute period: $minute_period minutes\n";
			# print FicheroSalida "Time: $f_checked_days[0][1]:$f_checked_days[0][2]\n";		
			for ($i =0; $i<scalar(@f_checked_days); $i++)
			{
				if ($f_checked_days[$i][0] ne "null")
				{
					$output_line ="\n$f_checked_days[$i][1]:$f_checked_days[$i][2], $f_checked_days[$i][3] $f_checked_days[$i][4] $f_checked_days[$i][5] \nLow percent: $f_checked_days[$i][6] %\nHigh percent: $f_checked_days[$i][7] %\n";
				}
				else
				{
					$output_line ="\nIt doesnt do it.\nLow percent: $f_checked_days[$i][6] %\nHigh percent: $f_checked_days[$i][7] %\n";
				}
				print $output_line;
				print FicheroSalida $output_line;
			}
			# We calculate high average and maximun low
			$sumOfHighNum = 0;
			$maxLow = 0;
			for ($i =0; $i<scalar(@f_checked_days); $i++)
			{
				if ($f_checked_days[$i][0] ne "null")
				{	
					if ($f_checked_days[$i][6]>$maxLow)
					{
						$maxLow = $f_checked_days[$i][6];
					}
					$sumOfHighNum = $sumOfHighNum + $f_checked_days[$i][7];
				}				
				
			}
			$highAverage = $sumOfHighNum/$impulse_num;
			print FicheroSalida "\n>> High average: ".$highAverage;
			print FicheroSalida "\n>> Maximun low: $maxLow";
			# We calculate standard deviation
			$sumOfStandDesv = 0;
			for ($i =0; $i<scalar(@f_checked_days); $i++)
			{
				if ($f_checked_days[$i][0] ne "null")
				{	
					$sumOfStandDesv = $sumOfStandDesv + abs($highAverage-$f_checked_days[$i][7]);
				}				
				
			}
			$highStdDev = $sumOfStandDesv/$impulse_num;
			print FicheroSalida "\n>> High standard deviation: $highStdDev\n";
						
			print FicheroSalida "***********************************************************************\n";
			close (FicheroSalida);
			check_1_next_days();
	} # if
		
	} # if  
		
	} # if
}
	

		


##########################################################################################################
## 												Main 													##
##########################################################################################################

					  
($sec,$min,$aux_hour,$mday,$mon,$aux_year,$wday,$yday,$isdst) = localtime(time);
print  "\n\n\n########################################\n";
printf "                     Hora de Inicio: %02d:%02d:%02d %02d-%02d-%4d\n",$aux_hour,$min,$sec,$mday,$mon+1,$aux_year+1900;
print  "########################################\n";


$database = "time_serie_db";
$host = "localhost";
$user = "root";
#$password = "12369";

$connection = DBI->connect("dbi:mysql:database=$database; host=$host", $user, $password) or die "Could not connect to the database: $!\n";

# $query_handle = $connection->prepare("SET NAMES 'utf8'"); 
# $query_handle->execute();


# $time_serie_file_name = "C:/Users/Binary_time_series.txt";
#$sucess_probability_file="C:/Users/file_of_2_impulses_research_ result.txt";














#################################### INPUT

$short_percent_c = 0.03; #0.05,0.01, 0.07, 0.005, 
$long_percent_c = 0.1;  #0.2,0.1,0.4,0.15

$sleep_seconds = 6;  # Second to sleep

$initial_year = 2016; 
$initial_month = "Dec"; # Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec

$sucess_probability_file = "E:/file_of_2_impulses_research_ result.txt";

$file_with_checkup = "E:/file_of_2_impulse_research_ result_summary.txt";



$start_success_probability = 55;
$final_success_probability = 70;



$start_num_of_days_to_check = 7;
$final_num_of_days_to_check = 11;



@time_series = 
(
"tise1",
"tise2"
);


@day_array = 
(
1,
2,
5,
6,
7,
8,
9,
12,
13,
14,
15,
16,
19,
20,
21,
22,
23
);








$success_probability=$start_success_probability; 
while ($success_probability < ($final_success_probability+1))

{







print "\nsuccess_probability: \'".$success_probability."\'\n";
print "\nshort_percent_c: \'".$short_percent_c."\'\n";
print "\nlong_percent_c: \'".$long_percent_c."\'\n";
print "\nsleep_seconds: \'".$sleep_seconds."\'\n";
print "\ninitial_year: \'".$initial_year."\'\n";
print "\ninitial_month: \'".$initial_month."\'\n";








for ($number_of_days_to_check=$start_num_of_days_to_check; $number_of_days_to_check < ($final_num_of_days_to_check+1); $number_of_days_to_check++)
{






$total_number_of_fails = 0;
$total_number_of_success = 0;
$total_number_of_checkups = 0;
$total_number_of_no_attemps = 0;

print "\nnumber_of_days_to_check: \'".$number_of_days_to_check."\'\n";

$max_null_day_num = int($number_of_days_to_check-($number_of_days_to_check*($success_probability/100 )));






for ($ind = 0; $ind < scalar(@time_series); $ind++ )
{






$time_serie = $time_series[$ind];	
	
print "\nIt read the time serie: \'".$time_serie."\'\n\n\n\n"; 






for ($day_ind = 0; $day_ind < scalar(@day_array); $day_ind++ )
{









$initial_day =$day_array[$day_ind];
print "\nDay read: \'".$day_array[$day_ind]."\'\n"; 	

	
$year = $initial_year;
$month = $initial_month;
$day = $initial_day;

$is_error = 0;

$min_hour = undef;
$query = "SELECT MIN(day_hour_f) AS min_hour FROM TB_MINUTE WHERE time_serie =\'$time_serie\' AND day = $day AND month=\'$month\' AND year=$year;";
$query_handle =$connection->prepare($query);
$query_handle->execute();
$row = $query_handle->fetchrow_hashref();
$min_hour = $row->{'min_hour'};
if (!defined($min_hour)) { print "\nError: Minimun hour is null\n"; sleep(60);$is_error=1;}	

$min_minute = undef;
$query = "SELECT MIN(hour_minute_f) AS min_minute FROM TB_MINUTE WHERE time_serie ='$time_serie' AND day = $day AND month='$month' AND year=$year";
$query_handle =$connection->prepare($query);
$query_handle->execute();
$row = $query_handle->fetchrow_hashref();
$min_minute = $row->{'min_minute'};
if (!defined($min_minute)) { print "\nError: Minimun minute is null\n";sleep(60);$is_error=1;}	

$max_hour = undef;
$query = "SELECT MAX(day_hour_f) AS max_hour FROM TB_MINUTE WHERE time_serie ='$time_serie' AND day = $day AND month='$month' AND year=$year";
$query_handle =$connection->prepare($query);
$query_handle->execute();
$row = $query_handle->fetchrow_hashref();
$max_hour = $row->{'max_hour'};
if (!defined($max_hour)) { print "\nError: Maximun hour is null\n";sleep(60);$is_error=1;}	

$max_minute = undef;
$query = "SELECT MAX(hour_minute_f) AS max_minute FROM TB_MINUTE WHERE time_serie ='$time_serie' AND day = $day AND month='$month' AND year=$year";
$query_handle =$connection->prepare($query);
$query_handle->execute();
$row = $query_handle->fetchrow_hashref();
$max_minute = $row->{'max_minute'};
if (!defined($max_minute)) { print "\nError: Maximun minute is null\n";sleep(60);$is_error=1;}	



if ($is_error == 0)
{




@period_array = (1); #1, 2, 5, 20, 60
for ($j=0; $j < scalar(@period_array); $j++ )
{



$minute_period =$period_array[$j];  
print "\nperiod_array[j]: $period_array[$j]\n";



$hour = $min_hour; 
$minute = $min_minute;

$last_minute  = $max_minute - ($minute_period % 60);
$last_hour = $max_hour- (int($minute_period / 60));

if ($last_hour >=$min_hour)
{

$continue = 1;

while ( $continue)
{ 	
	
	$year = $initial_year;
	$month = $initial_month;
	$day = $initial_day;
	
	@checked_days = (["null",0,0,0,"null",0,0,0]);
	$finish = 0;
	$not_impulse_number = 0;
	$day_num = 0; 
	$previous_day_found =1;
	while ( $day_num < $number_of_days_to_check && $previous_day_found )
	{

		 ($l_percent,$h_percent,$rule) = check_day($time_serie, $minute, $hour, $day, $month, $year,$minute_period);
		
		if ($rule >0) 
		{ 
			$checked_days[$day_num][0] = $time_serie; $checked_days[$day_num][1] = $hour;	$checked_days[$day_num][2] = $minute;	$checked_days[$day_num][3] = $day;
			$checked_days[$day_num][4] = $month;	$checked_days[$day_num][5] = $year;	$checked_days[$day_num][6] = $l_percent;$checked_days[$day_num][7] = $h_percent;
		}
		else
		{
			$checked_days[$day_num][0] = "null"; $checked_days[$day_num][1] = 0; $checked_days[$day_num][2] = 0; $checked_days[$day_num][3] = 0;
			$checked_days[$day_num][4] = "null";	$checked_days[$day_num][5] = 0;$checked_days[$day_num][6] = $l_percent;$checked_days[$day_num][7] = $h_percent;
			$checked_days[$day_num][7] = 0;

			$not_impulse_number++;
			if ($not_impulse_number>$max_null_day_num)
			{
				$finish = 1;
				$day_num=$number_of_days_to_check;
			}						
			
		}
					
				
		($day, $month, $year, $previous_day_found) = next_day($time_serie, $minute, $hour, $day, $month, $year);			
		$day_num++;
		
	} # while
	
	if (!$finish)
	{		
		check_day_array(@checked_days);
	}		
	
	($hour, $minute) = next_time($hour, $minute, 1);
	
	if ($minute==0)
	{
			print "\ntime_serie, day, month, year, minute_period, hour, minute:  $time_serie, $initial_day, ".$initial_month.", ".$initial_year.", $minute_period, $hour:$minute\n"; 
			# print "\ntime_serie, minute_period,hour, minute:  $time_serie,  $minute_period, $hour:$minute: \n"; 
			print "\nSleeping ... \n"; 	sleep($sleep_seconds); print "\nProcessing ... \n"; 	
	}
	# if ($minute==7)	{	print "\nSleeping ... \n"; 	sleep(5);	print "\nProcessing ... \n"; 	}
	if ($minute==15)	{	print "\nSleeping ... \n"; 	sleep($sleep_seconds);	print "\nProcessing ... \n"; 	}
	# if ($minute==22)	{	print "\nSleeping ... \n"; 	sleep(5);	print "\nProcessing ... \n"; 	}
	if ($minute==30)	{	print "\nSleeping ... \n"; 	sleep($sleep_seconds);	print "\nProcessing ... \n"; 	}
	# if ($minute==38)	{	print "\nSleeping ... \n"; 	sleep(5);	print "\nProcessing ... \n"; 	}
	if ($minute==45)	{	print "\nSleeping ... \n"; 	sleep($sleep_seconds);	print "\nProcessing ... \n"; 	}
	# if ($minute==53)	{	print "\nSleeping ... \n"; 	sleep(5);	print "\nProcessing ... \n"; 	}			
			
	if  ($hour== $last_hour) 
	{
		if  ($minute<$last_minute)
		{
			$continue = 1;
		}
		else
		{
			$continue = 0;
		}
		
	}			
	
} # while minutes of day


print "\ntime_serie, day, month, year, minute_period, hour, minute:  $time_serie, $day, $month, $year, $minute_period, $hour:$minute\n"; 
# print "\ntime_serie, minute_period,hour, minute:  $time_serie,  $minute_period, $hour:$minute\n"; 
# print "\nSleeping ... \n"; 		
# sleep(60);
# print "\nProcessing ... \n"; 	


} # if $last_hour

	
} # for period_array


} # if is_error


} # for day array


print "\n*****************************************           END OF TIME SERIE           *****************************************\n"; 
# print "\ntime_serie, minute_period,hour, minute:  $time_serie,  $minute_period, $hour:$minute\n"; 
# print "\nSleeping ... \n"; 			
# sleep(60);
# print "\nProcessing ... \n"; 	


open (FicheroSalida3,">>".$file_with_checkup) || die "ERROR: No se pudo abrir el fichero ".$file_with_checkup."\n";
print FicheroSalida3 "$time_serie\n";
print FicheroSalida3 "Success probability: $success_probability\n";
print FicheroSalida3 "Number of days to ckeck: $number_of_days_to_check\n";
print FicheroSalida3 "SUCCESS, ";
if ($total_number_of_checkups!=0)
{
	print FicheroSalida3 "Sucess ratio: $total_number_of_success of $total_number_of_checkups , sucess percent: ".(($total_number_of_success/$total_number_of_checkups)*100)." %\n";
} else {print FicheroSalida3 "Sucess ratio: $total_number_of_success of $total_number_of_checkups , sucess percent: inf %\n";}
print FicheroSalida3 "No attemp, ";	
if ($total_number_of_checkups!=0)
{
	print FicheroSalida3 "No attemp ratio: $total_number_of_no_attemps of $total_number_of_checkups , No attemp percent: ".(($total_number_of_no_attemps/$total_number_of_checkups)*100)." %\n";
} else {print FicheroSalida3 "No attemp ratio: $total_number_of_no_attemps of $total_number_of_checkups , No attemp percent: inf %\n";}
print FicheroSalida3 "Failure, ";
if ($total_number_of_checkups!=0)
{
	print FicheroSalida3 "Failure ratio: $total_number_of_fails of $total_number_of_checkups , Failure percent: ".(($total_number_of_fails/$total_number_of_checkups)*100)." %\n";
} else {print FicheroSalida3 "Failure ratio: $total_number_of_fails of $total_number_of_checkups , Failure percent: inf %\n";}
print FicheroSalida3 "eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee\n";
close (FicheroSalida3);


} # for symbol array



} # for number_of_days_to_check


$success_probability=$success_probability+5;
} # while success_probability



open (FicheroSalida,">>".$sucess_probability_file) || die "ERROR: No se pudo abrir el fichero ".$sucess_probability_file."\n";
print FicheroSalida "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
close (FicheroSalida);


open (FicheroSalida3,">>".$file_with_checkup) || die "ERROR: No se pudo abrir el fichero ".$file_with_checkup."\n";
print FicheroSalida3 "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
close (FicheroSalida3);	

	
$connection->disconnect();


($sec,$min,$aux_hour,$mday,$mon,$aux_year,$wday,$yday,$isdst) = localtime(time);
print  "\n\n\n########################################\n";
printf "                        Hora de Fin: %02d:%02d:%02d %02d-%02d-%4d\n",$aux_hour,$min,$sec,$mday,$mon+1,$aux_year+1900;
print  "########################################\n";