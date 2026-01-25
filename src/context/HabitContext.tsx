import React, { createContext, useContext, useReducer, useEffect } from 'react';
import { v4 as uuidv4 } from 'uuid';
import { Habit, HabitState, HabitAction } from '../types/habit';
import { getWeekStart, formatDate } from '../utils/dateUtils';
import { saveHabits, loadHabits } from '../utils/storage';

const initialState: HabitState = {
  habits: [],
  currentWeekStart: getWeekStart(new Date()),
};

function habitReducer(state: HabitState, action: HabitAction): HabitState {
  switch (action.type) {
    case 'ADD_HABIT': {
      const newHabit: Habit = {
        id: uuidv4(),
        name: action.payload.name,
        color: action.payload.color,
        completedDates: [],
        createdAt: formatDate(new Date()),
      };
      return {
        ...state,
        habits: [...state.habits, newHabit],
      };
    }
    case 'DELETE_HABIT': {
      return {
        ...state,
        habits: state.habits.filter((h) => h.id !== action.payload),
      };
    }
    case 'TOGGLE_DAY': {
      return {
        ...state,
        habits: state.habits.map((habit) => {
          if (habit.id !== action.payload.habitId) return habit;
          const isCompleted = habit.completedDates.includes(action.payload.date);
          return {
            ...habit,
            completedDates: isCompleted
              ? habit.completedDates.filter((d) => d !== action.payload.date)
              : [...habit.completedDates, action.payload.date],
          };
        }),
      };
    }
    case 'SET_WEEK': {
      return {
        ...state,
        currentWeekStart: getWeekStart(action.payload),
      };
    }
    case 'LOAD_HABITS': {
      return {
        ...state,
        habits: action.payload,
      };
    }
    default:
      return state;
  }
}

interface HabitContextType {
  state: HabitState;
  dispatch: React.Dispatch<HabitAction>;
}

const HabitContext = createContext<HabitContextType | null>(null);

export function HabitProvider({ children }: { children: React.ReactNode }) {
  const [state, dispatch] = useReducer(habitReducer, initialState);

  // Load habits from localStorage on mount
  useEffect(() => {
    const savedHabits = loadHabits();
    if (savedHabits.length > 0) {
      dispatch({ type: 'LOAD_HABITS', payload: savedHabits });
    }
  }, []);

  // Save habits to localStorage whenever they change
  useEffect(() => {
    saveHabits(state.habits);
  }, [state.habits]);

  return (
    <HabitContext.Provider value={{ state, dispatch }}>
      {children}
    </HabitContext.Provider>
  );
}

export function useHabits() {
  const context = useContext(HabitContext);
  if (!context) {
    throw new Error('useHabits must be used within a HabitProvider');
  }
  return context;
}
