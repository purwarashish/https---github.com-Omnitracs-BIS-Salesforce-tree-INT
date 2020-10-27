/*******************************************************************************
 * File:  CRDateBasedLineChartController.cls
 * Date:  Sep 22, 2009  
 * Author:  Charlie Heaps
 *
 * The use, disclosure, reproduction, modification, transfer, or transmittal of
 * this work for any purpose in any form or by any means without the written 
 * permission of United Parcel Service is strictly prohibited.
 *
 * Confidential, unpublished property of United Parcel Service.
 * Use and distribution limited solely to authorized personnel.
 *
 * Copyright 2009, UPS Logistics Technologies, Inc.  All rights reserved.
 * *******************************************************************************/
 
public class CRDateBasedLineChartController 
{
    public CRDateBasedLineChartController()
    {
        yData = new Integer[0];
        yDataDecimal = new Decimal[0];//  decimal array for using decimal y data for a graph
        shouldUseDecimalValues = false;//  initlize this to false, its up to component to set this to true if user wants to use decimal values
    }
    
    public String createGoogleChartURL()
    {
        String url = 'http://chart.apis.google.com/chart?';
        
        // Chart type (line chart)
        url += 'cht=lc&';
        
        // Chart size
        url += 'chs=' + width.format() + 'x' + height.format() + '&';
                
        // Axis styles, colors
        url += 'chxs=0,000000|1,000000|2,000000&';
        url += 'chxt=x,y,r&';
        
        //  this method makes sure the data in the ydata/ydataDecimal array is correct.  it then will strip data points
        //  from the beginning of the array to ensure that the date labels display properly on the screen.
        checkAndStripDataPointsIfNeeded();

        url = addDateAxisLabelsToURL(url);//  add the data labels before the data points--this way i can introduce a method
        //  before this method that will strip the number of data points from the ydata array
        
        if (!shouldUseDecimalValues)//  this uses the original functionality of this controller... integer values
        {
            if ( (yData.size() == 0) && (yDataDecimal.size() != 0) )
            {
                system.debug('Decimal data is defined for yData but nothing is specified for integer data.  Did you forget ' +
                  ' to set the useDecimalValues attirbute in the xml?');
            }
            url = addDataToURL(url);
        }
        else //  use the ydata that is stored in the decimal to contstruct the url
        {
            url = addDataToUrlUsingDecimalValues(url);
        }
        return url;
    }
    
    private void checkAndStripDataPointsIfNeeded()
    {
        //  the optimal (not the only way) to display the date labels is the # of data points per series is if the number of data points - 1
        //  is less than 53 AND the that number is divisble by 4.  for example, lets say the number of data points = 13. that would make
        //  the magic number 12 which is divisble by, 4, we can display the date labels with that data set.
        //  now if the magic number is not easily divisble by 4 OR greater than 53 then we need to trim some data values.
        displayDataPointsOnDebugLog();
           
        if (!shoulduseDecimalValues)
        {
            system.debug('ctrlf ********************** size of ydata array = ' + yData.size());
        }
        else
        {
            system.debug('ctrlf ********************** size of ydata array = ' + yDataDecimal.size());
        }
                
        if (getNumberPointsPerSeries() < 5)
        {
            throw new myException('This controller cannot display date labels properly for ' +
              'a set of data smaller than 5 data points per series.');
        }
        if (getNumberPointsPerSeries() > 53)
        {
            //  if the number of data points is greater than 53, we want to strip data points until the number of points is exactly 53
            while (getNumberPointsPerSeries() > 53)
            {
                stripDataPointFromYdataArrayOrYDataDecimal();//  strips one data point per numSeries at a time.
            }
        }
        if (getNumberPointsPerSeries() < 53)//  numer of data points is less than 54
        {
            //  while the number of points per series is not divisible by 4
            while (Math.Mod((getNumberPointsPerSeries() - 1), 4) != 0)
            {
                stripDataPointFromYdataArrayOrYDataDecimal();//  strips one data point per numSeries at a time.
            }
        }
        
        displayDataPointsOnDebugLog();
        
        if (!shoulduseDecimalValues)
        {
            system.debug('ctrlf ********************** size of ydata array = ' + yData.size());
        }
        else
        {
            system.debug('ctrlf ********************** size of ydata array = ' + yDataDecimal.size());
        }
    }
    
    private void displayDataPointsOnDebugLog()
    {
        string debugValues = '';
        integer numSeriesCount = 0;
        if (!shouldUseDecimalvalues)
        {
            for (integer i = 0; i < ydata.size(); i++)
            {
                if (numSeriesCount >=  numSeries)
                {
                    debugValues += ' || ';
                    numSeriesCount = 0;
                }
                debugValues += ydata[i] + ', ';
                numSeriesCount++;
                
            }
        }
        else 
        {
            for (integer i = 0; i < yDataDecimal.size(); i++)
            {
                if (numSeriesCount >=  numSeries)
                {
                    debugValues += ' || ';
                    numSeriesCount = 0;
                }
                debugValues += yDataDecimal[i] + ', ';
                numSeriesCount++;
                
            }
        
        }
        system.debug('ctlrf *************************** data = ' + debugValues);        
    }
    
    private void stripDataPointFromYdataArrayOrYDataDecimal()
    {
        if (!shouldUseDecimalValues)
        {
            //  prevents from removing more items from the array then the array has.  shouldnt happen but you never know
            //system.debug(ydata.size() >= numSeries);
            integer numberOfDataPointsPerSeries = getNumberPointsPerSeries();
        
            //  we remove the first number from the array, jump to the next data point set, remove the first data point there and so forth
            //  for example, lets say we have 18 data points in total, the num series is 3
            //  the data would look like this:
            //  Line 1 = 2, 5, 3, 5, 3, 2
            //  Line 2 = 0, 2, 5, 9, 1, 9
            //  Line 3 = 4, 4, 2, 3, 5, 8
            //  Now,  the data points get populated to the url like this: Line 1 data points | Line 2 data points | Line 3 Data points
            //  so in the above example we would have this:  2, 5, 3, 5, 3, 2|0, 2, 5, 9, 1, 9|4, 4, 2, 3, 5, 8
            //  if we wanted to remove the first point from each line, we need to remove the values 2, 0, and 4.  
            //  how do we do that in a for loop?
            //  well, the number of points per series is 6.  the size of the array is 18.  we start at the 0th element,remove that data point
            //  now, because we removed that first element, the size of teh array is now 1 less than what is was previously
            //  we now increment to the next set of data, which would mean we move 6 elements in the array, but since we removed the first element
            //  we increment to 5 elements in the array.
            //  so in our example, i = 6 - 1 = 5.  the 5th element in the above array is 0.
            //  we remove the 5th element. and incrment i by 5 again.
            //  i is now pointing to the value of 4.  we remove that.  since there are only
            //  3 lines (num series) we stop.  we have removed the first data points for each line.         
            for (integer i = 0; i < yData.size(); i+= ( numberOfDataPointsPerSeries - 1) )
            {
                yData.remove(i);
            }
        }
        else
        {
            //system.debug(ydataDecimal.size() >= numSeries);
            integer numberOfDataPointsPerSeries = getNumberPointsPerSeries();
            for (integer i = 0; i < yDataDecimal.size(); i+= ( numberOfDataPointsPerSeries - 1) )
            {
                yDataDecimal.remove(i);
            }
        }
    }
    
    private String addDataToUrlUsingDecimalValues(String url)
    {
        //util.debug('inside of addDataToUrlUsingDecimalValues');
        //  this is a mirror copy of the addDataToUrl except for integers we use decimals
        if (yDataDecimal == null)
        {
            return url;
        }

        String outURL = url + 'chd=t:';
        
        Integer numPoints = yDataDecimal.size();
        Integer numPointsPerSeries = numPoints/numSeries;
        Decimal value;
        //util.debug('about to add first set of values.... numpoints = ' + numPoints + ' numPointtsPerSeriess = ' + numPointsPerSeries);
                
        for (Integer i = 0; i < numSeries; i++)
        {
            if (i != 0)
            {
                outURL += '|';
            }

            for (Integer j = 0; j < numPointsPerSeries; j++)
            {
                if (j != 0)
                {
                    outURL += ',';
                }
                value = yDataDecimal[i*numPointsPerSeries + j];

                outURL += value != null ? value.format() : '-1';
            }
        }
        //util.debug('finished asdding first data.  outurl = ' + outurl);        
        outURL += '&';
        
        
        //util.debug('about to add second set of data. datalabels = ' + datalabels);
        // Data labels for legend
        //  joseph comment here, steve asked one of my charts on the cr metrics page NOT show a label if hte pageblocksection title states what the graph is for
        //  since im using this compenent, i tried to pass a null vlaue in the datalabels property and got a null message. so im going to add logic here that if
        // the datalabels array is blank, then dont add the datalabel 
        if (dataLabels != null && dataLabels.size() > 0)
        {
            outURL += 'chdl=';
        
            for (Integer i = 0; i < numSeries; i++)
            {
                if (i != 0)
                {
                    outURL += '|';
                }           
                outURL += dataLabels[i];
            }       
            
            
            outURL += '&';
        }
        //util.debug('finished adding second set of data.  outurl = ' + outurl);
        
        // put legend at top of chart
        outURL += 'chdlp=t&';
        
        // Data colors
        
        outURL += 'chco=';
        
        //util.debug('finally, about to add third set of data.  numSEries = ' + numSeries);
        for (Integer i = 0; i < numSeries; i++)
        {
            if (i != 0)
            {
                outURL += ',';
            }           
            outURL += dataColors[i];
        }       
        
        outURL += '&';
        //util.debug('this method is finished addDataToUrlUsingDecimalValues. reutnring outurl of ' + outurl);
        return outURL;
    }
    
    private String addDataToURL(String url)
    {
        if (yData == null)
        {
            return url;
        }

        String outURL = url + 'chd=t:';
        
        Integer numPoints = yData.size();
        Integer numPointsPerSeries = numPoints/numSeries;
        Integer value;
        
        for (Integer i = 0; i < numSeries; i++)
        {
            if (i != 0)
            {
                outURL += '|';
            }

            for (Integer j = 0; j < numPointsPerSeries; j++)
            {
                if (j != 0)
                {
                    outURL += ',';
                }
                value = yData[i*numPointsPerSeries + j];
      
                outURL += value != null ? value.format() : '-1';
            }
        }
        
        
        outURL += '&';
        
        // Data labels for legend
        
        outURL += 'chdl=';
        
        for (Integer i = 0; i < numSeries; i++)
        {
            if (i != 0)
            {
                outURL += '|';
            }           
            outURL += dataLabels[i];
        }       
        
        outURL += '&';

        // put legend at top of chart
        outURL += 'chdlp=t&';
        
        // Data colors
        
        outURL += 'chco=';
        
        for (Integer i = 0; i < numSeries; i++)
        {
            if (i != 0)
            {
                outURL += ',';
            }           
            outURL += dataColors[i];
        }       
        
        outURL += '&';
        
        return outURL;
    }
    
    private String addDateAxisLabelsToURL(String url)
    {
        //system.debug('ctrlf ******* insside of dataAxisLabelsToURL method');        
        // Put month labels on the X axis.
        String outURL = url + 'chxl=0:';
        
        Integer numberOfDataPointsPerSeries = getNumberPointsPerSeries();
        Integer dateLabelInterval = 4;//   4 is optimal for 53 weeks of data

        //  set date value to be the end date.                                
        Datetime dateValue = Datetime.newInstance(endDate.year(), endDate.month(), endDate.day());
                
        string dateLabel = '';
        
        //system.debug('ctrlf ******* beginning for loop, scrolling thru numberOfDataPonitsPerSeries');
        
        for (Integer i = (numberOfDataPointsPerSeries - 1); i > -1; i--)
        {
            if (i == (numberOfDataPointsPerSeries - 1) )//  if its the last date label, add the 2 digit year
            {
                dateLabel = '|' + dateValue.format('dd MMM yy') + dateLabel;
            }
            else if (i == 0)//  if its the first date label, add the 2 digit year
            {
                dateLabel = '|' + dateValue.format('dd MMM yy') + dateLabel;
            }
            else if (Math.Mod(i, dateLabelInterval) == 0)//  display the date label every nth data grid line
            {           
               dateLabel = '|' + dateValue.format('dd MMM') + dateLabel;
            }
            else
            {
                dateLabel = '|' + dateLabel;
            }
            
            dateValue = dateValue.addDays(-7);
        }
        
        dateLabel += + '&';
                
        outURL += dateLabel;
        
        //system.debug('ctrlf **************************** assigning range' );
        // Y axis range and label interval
        Integer range = yDataMax - yDataMin;
        
        //system.debug('ctrlf **************************** range = ' + range );
        
        double interval = 0;
        
        //  an internal server error was coming up because if you take the log10 of 0 you get -infinity. floor of -infinity is -infinity. 
        //  when you attempt to take the power of 10^(-infinty - 1) the internal server is thrown 
        //  ( -infinty - 1 is still infiinty. taking 10 to the -inifinty is, umm, a pretty big negative number).  
        //  for now i'll default the interval to 1 until i figure out what it should probably be set to
        if (range == 0)
        {
            interval = 1;
        }
        else
        {
            double log10 = Math.log10(range);
            double floor = Math.floor(log10); 
            // Get an initial interval. 
            interval = Math.pow(10, floor - 1);// Example: interval = 10 raised to the power of (floor(3.61) - 1) = 10 to power of 2 = 100
            
        }
        
        // Get the number of intervals
        Integer count = (range / interval).intValue();
        // Example: count = 4100 / 100 = 41
        
        // Adjust the interval so that there aren't too many or too few ticks.
        if (10 < count && count < 20)
        {
            interval *= 2;
        }
        else if (20 <= count && count < 50)
        {
            interval *= 5;
        }
        else if (50 <= count && count < 100)
        {
            interval *= 10;
        }
        
        count = (range / interval).intValue();
        
        // add whatever interval is to the max value so that the highest data point is displayed on the screen without being cut off
        Integer maxValue = ( yDataMin + (count * interval ) ).intValue() + interval.intValue();
       
        // Y axis range. Labels are taken from the range.
        
        outURL += 'chxr=1,' + yDataMin.format() + ',' + maxValue.format() + ',' + interval.intValue().format();
        
        // Labels on the right side of chart also.
        outURL += '|2,' + yDataMin.format() + ',' + maxValue.format() + ',' + interval.intValue().format() + '&';
        
        // Data scaling
        
        outURL += 'chds=' + yDataMin.format() + ',' + maxValue.format() + '&'; 

        // Grid lines
        //  it is possible for count to be zero if the range is 0 and the max value is 0. in that case we dont divide by 0.
        //  we divide by one and hope the graph still renders properly.
        outURL += 'chg=-1,';
        outURL += (count == 0 ? (100/1).format() : (100/count).format());
        outURL += '&';
        
        system.debug('ctrlf ******* finsihed dataAxisLabelsToURL method returning outurl which is = ' + outUrl);
        
        return outURL;
    }
    
    
    private String m_googleChartURL = null;
      
    private integer getNumberPointsPerSeries()
    {
        if (shouldUseDecimalValues)
        {
            return ydataDecimal.size() / numSeries;
        }
        else
        {
            return yData.size() / numSeries;
        }
    }
    
    public String googleChartURL 
    {
        get
        {
            system.debug('ctrlf *************** googleChartURL getter called.');
            if (m_googleChartURL == null)
            {
                m_googleChartURL = createGoogleChartURL();
            }       
            
            system.debug('ctrlf *************** getter finished, return url. here it is ' + m_googleChartURL);
            return m_googleChartURL;
        }
    }
    
    public String title {get; set;}
    public Integer[] yData {get; set;}//  this is no longer required by the component because you could set this or the decimal equalvilent
    public Decimal[] yDataDecimal{get; set;}//  used to hold decimal values 
    public Integer yDataMin {get; set;}
    public Integer yDataMax //  this no no longer needs to be set by the calling class, it is computed each get
    {
        get
        {
            if (!shouldUseDecimalValues)
            {
                return retrieveYDataMax(yData);
            }
            else
            {
                return retrieveYDataDecimalMax(yDataDecimal);
            }
        }
        set
        {
           yDataMax = value;    
        }
    }
    public Integer numSeries {get; set;}
    public String[] dataColors {get; set;}
    public String[] dataLabels {get; set;}
    public Date beginDate {get; set;}
    public Date endDate {get; set;}
    public Integer width {get; set;}
    public Integer height {get; set;}
    //  set in the component, if true then the url thats is constructed will contain data from the decimal array values
    public Boolean shouldUseDecimalValues{get; set;}
    
    public class myException extends Exception{}//  used to test various parts of new additions
    
    private static integer retrieveYDataMax(List<integer> numbers)
    {
        if (numbers.size() == 0)//  return 100 if there no numbers in the list
        {
            return 100;
        }
        
        integer maxValue = numbers[0];//  assume first item in the list is the lowest value
        
        for (Integer valueToCheck : numbers)//  go thru each item in the list and check for higher values
        {
           if (valueToCheck > maxValue)//  if the item in the list is less then max value
           {
               maxValue = valueToCheck;  //  assign that value as max value
           }
        }
        
        return maxValue;
    }
    
    private static integer retrieveYDataDecimalMax(List<decimal> numbers)
    {
        if (numbers.size() == 0)//  return 100 if there no numbers in the list
        {
            return 100;
        }
        
        decimal maxValue = numbers[0];//  assume first item in the list is the lowest value
        
        for (decimal valueToCheck : numbers)//  go thru each item in the list and check for higher values
        {
           if (valueToCheck > maxValue)//  if the item in the list is less then max value
           {
               maxValue = valueToCheck;  //  assign that value as max value
           }
        }
        
        return maxValue.intValue();
    }
    // Test methods    
   
}