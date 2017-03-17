//
//  Date.hpp
//  FMDB-CPP
//
//  Created by hejunqiu on 2017/2/10.
//  Copyright © 2017年 CHE. All rights reserved.
//

#ifndef DATE_HPP
#define DATE_HPP

#include "global.h"
#include <iosfwd>

CC_BEGIN

CC_EXTERN const TimeInterval TimeIntervalSince1970;

class Date {
    system_clock::time_point d;
public:
    using time_point = system_clock::time_point;
    explicit Date(time_point) NOEXCEPT;

    /**
     Creates and returns a new date set to the current date and time.
     */
    Date() NOEXCEPT;

    /**
     Creates and returns an NSDate object set to a given number of seconds from 00:00:00 UTC on 1 January 2001.

     @param SinceReferenceDate The number of seconds from the absolute reference date (00:00:00 UTC on 1 January 2001) for the new date. Use a negative argument to specify a date and time before the reference date.
     */
    explicit Date(TimeInterval SinceReferenceDate) NOEXCEPT;
    ~Date() NOEXCEPT;


    /**
     Returns a copy date that is same to this date.

     @return A copy date.
     */
    Date clone() NOEXCEPT;


    /**
     Returns the interval between this and another given date.

     @param anotherDate The date with which to compare this.
     @return The interval between this and the anotherDate parameter. If the receiver is earlier than anotherDate, the return value is negative.
     */
    TimeInterval timeIntervalSinceDate(Date anotherDate) const NOEXCEPT;


    /**
     The time interval between the date object and the current date and time.
     If the date object is earlier than the current date and time, this value is negative.

     @return The interval between this and the current date.
     */
    TimeInterval timeIntervalSinceNow() const NOEXCEPT;

    /**
     The interval between the date object and 00:00:00 UTC on 1 January 1970.
     This value is negative if the date object is earlier than 00:00:00 UTC on 1 January 1970.

     @return The interval between this and the date(00:00:00 UTC on 1 January 1970).
     */
    TimeInterval timeIntervalSince1970() const NOEXCEPT;

    /**
     Returns the interval between the date object and 00:00:00 UTC on 1 January 2001.
     This value is negative if the date object is earlier than the system’s absolute reference date (00:00:00 UTC on 1 January 2001).

     @return The interval between this and the date(00:00:00 UTC on 1 January 2001).
     */
    TimeInterval timeIntervalSinceReferenceDate() const NOEXCEPT;


    /**
     Returns a new Date object that is set to a given number of seconds relative to the receiver.

     @param seconds The number of seconds to add to this. Use a negative value for seconds to have the returned object specify a date before this date.
     @return A new Date object that is set to seconds seconds relative to this. The date returned might have a representation different from this.
     */
    Date dateByAddingTimeInterval(TimeInterval seconds) const NOEXCEPT;

    static Date dateWithTimeIntervalSinceNow(TimeInterval secs) NOEXCEPT;
    static Date dateWithTimeIntervalSince1970(TimeInterval secs) NOEXCEPT;
    static Date dateWithTimeIntervalSinceReferenceDate(TimeInterval ti) NOEXCEPT;
    static Date dateWithTimeInterval(TimeInterval secsToAdded, Date sinceDate) NOEXCEPT;
    static Date dateEpoch() NOEXCEPT;
    static Date dateFromString(const std::string &dateString) NOEXCEPT;

    static string stringFromDate(const Date &date) NOEXCEPT;

    string description() const NOEXCEPT;

    /* operators */

    /**
     Add clocks to date.
     @param clocks clock type value. nanoseconds, microseconds, milliseconds, seconds, minutes, hours or any duration else.
     @return return self
     */
    template<typename clock_type>
    Date& operator += (const clock_type &clocks) NOEXCEPT
    {
        d += duration_cast<system_clock::duration>(clocks);
        return *this;
    }

    /**
     Minus clocks to date.
     @param clocks clock type value. nanoseconds, microseconds, milliseconds, seconds, minutes, hours or any duration else.
     @return return self
     */
    template<typename clock_type>
    Date& operator -= (const clock_type &clocks) NOEXCEPT
    {
        d -= duration_cast<system_clock::duration>(clocks);
        return *this;
    }

    /**
     Create a new date which has been minused clocks from this date.
     @param clocks clock type value. nanoseconds, microseconds, milliseconds, seconds, minutes, hours or any duration else.
     @return return self
     */
    template<typename clock_type>
    Date operator - (const clock_type &clocks) NOEXCEPT
    {
        auto copy = clone();
        copy.d -= clocks;
        return copy;
    }

    /**
     Create a new date which has been added clocks from this date.
     @param clocks clock type value. nanoseconds, microseconds, milliseconds, seconds, minutes, hours or any duration else.
     @return return self
     */
    template<typename clock_type>
    Date operator + (const clock_type &clocks) NOEXCEPT
    {
        auto copy = clone();
        copy.d += clocks;
        return copy;
    }

	bool operator==(const Date &rhs) const NOEXCEPT { return this->d == rhs.d; }
	bool operator!=(const Date &rhs) const NOEXCEPT { return !(*this == rhs); }

	friend std::ostream& operator<<(std::ostream &os, const Date &date) NOEXCEPT
    {
        os << date.description();
        return os;
    }
};

CC_END

#endif /* DATE_HPP */
