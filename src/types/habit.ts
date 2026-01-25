export interface Habit {
  id: string;
  name: string;
  color: string;
  completedDates: string[]; // ISO date strings (YYYY-MM-DD)
  createdAt: string;
}

export interface HabitState {
  habits: Habit[];
  currentWeekStart: Date;
}

export type HabitAction =
  | { type: 'ADD_HABIT'; payload: Omit<Habit, 'id' | 'createdAt' | 'completedDates'> }
  | { type: 'DELETE_HABIT'; payload: string }
  | { type: 'TOGGLE_DAY'; payload: { habitId: string; date: string } }
  | { type: 'SET_WEEK'; payload: Date }
  | { type: 'LOAD_HABITS'; payload: Habit[] };
