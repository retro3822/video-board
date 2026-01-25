import { useHabits } from '../context/HabitContext';
import {
  formatWeekRange,
  getPreviousWeek,
  getNextWeek,
  getWeekStart,
} from '../utils/dateUtils';

export function WeekNavigation() {
  const { state, dispatch } = useHabits();
  const { currentWeekStart } = state;

  const handlePrevious = () => {
    dispatch({ type: 'SET_WEEK', payload: getPreviousWeek(currentWeekStart) });
  };

  const handleNext = () => {
    dispatch({ type: 'SET_WEEK', payload: getNextWeek(currentWeekStart) });
  };

  const handleToday = () => {
    dispatch({ type: 'SET_WEEK', payload: getWeekStart(new Date()) });
  };

  return (
    <div className="flex items-center justify-between mb-6">
      <button
        onClick={handlePrevious}
        className="p-2 rounded-lg hover:bg-gray-200 transition-colors"
        aria-label="Previous week"
      >
        <svg
          className="w-5 h-5"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth={2}
            d="M15 19l-7-7 7-7"
          />
        </svg>
      </button>

      <div className="flex items-center gap-4">
        <h2 className="text-lg font-semibold text-gray-700">
          {formatWeekRange(currentWeekStart)}
        </h2>
        <button
          onClick={handleToday}
          className="px-3 py-1 text-sm bg-indigo-100 text-indigo-700 rounded-full hover:bg-indigo-200 transition-colors"
        >
          Today
        </button>
      </div>

      <button
        onClick={handleNext}
        className="p-2 rounded-lg hover:bg-gray-200 transition-colors"
        aria-label="Next week"
      >
        <svg
          className="w-5 h-5"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth={2}
            d="M9 5l7 7-7 7"
          />
        </svg>
      </button>
    </div>
  );
}
