import { Habit } from '../types/habit';

const STORAGE_KEY = 'weekly-habit-tracker';

export function saveHabits(habits: Habit[]): void {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(habits));
  } catch (error) {
    console.error('Failed to save habits to localStorage:', error);
  }
}

export function loadHabits(): Habit[] {
  try {
    const data = localStorage.getItem(STORAGE_KEY);
    if (data) {
      return JSON.parse(data);
    }
  } catch (error) {
    console.error('Failed to load habits from localStorage:', error);
  }
  return [];
}
