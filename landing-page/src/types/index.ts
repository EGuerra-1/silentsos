export interface Feature {
  icon: string;
  iconFilled?: boolean;
  iconBgClass: string;
  iconColorClass: string;
  title: string;
  description: string;
  decorativeIcon?: string;
}

export interface ProcessStep {
  number: number;
  title: string;
  description: string;
  completed?: boolean;
}

export interface AccessibilityItem {
  icon: string;
  title: string;
  description: string;
}
