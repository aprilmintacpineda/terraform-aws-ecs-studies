import React, { useState, useEffect } from 'react';
import { formatDistanceToNow } from 'date-fns';

type Props = {
  startDate: string;
};

const TimeAgo: React.FunctionComponent<Props> = ({ startDate }) => {
  const [timeAgo, setTimeAgo] = useState(() => {
    return formatDistanceToNow(new Date(startDate), {
      addSuffix: true
    });
  });

  useEffect(() => {
    function recalc() {
      setTimeAgo(
        formatDistanceToNow(new Date(startDate), { addSuffix: true })
      );
    }

    const timer = setInterval(recalc, 1000);

    return () => {
      clearInterval(timer);
    };
  }, [startDate]);

  return timeAgo;
};

export default TimeAgo;
