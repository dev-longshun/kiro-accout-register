import { create } from 'zustand'

export interface RegisterAccount {
  id: string
  email: string
  password: string
  refreshToken: string
  clientId: string
  status: 'pending' | 'activating' | 'registering' | 'getting_code' | 'success' | 'failed' | 'exists'
  awsName?: string
  ssoToken?: string
  error?: string
}

interface AutoRegisterState {
  // 注册账号列表
  accounts: RegisterAccount[]
  // 是否正在运行
  isRunning: boolean
  // 日志
  logs: string[]
  // 并发数
  concurrency: number
  // 是否跳过 Outlook 激活
  skipOutlookActivation: boolean
  // 停止标志
  shouldStop: boolean
}

interface AutoRegisterActions {
  // 添加账号
  addAccounts: (accounts: RegisterAccount[]) => void
  // 清空账号
  clearAccounts: () => void
  // 更新账号状态
  updateAccountStatus: (id: string, updates: Partial<RegisterAccount>) => void
  // 添加日志
  addLog: (message: string) => void
  // 清空日志
  clearLogs: () => void
  // 设置运行状态
  setIsRunning: (running: boolean) => void
  // 设置并发数
  setConcurrency: (concurrency: number) => void
  // 设置跳过 Outlook 激活
  setSkipOutlookActivation: (skip: boolean) => void
  // 请求停止
  requestStop: () => void
  // 重置停止标志
  resetStop: () => void
  // 获取统计
  getStats: () => {
    total: number
    pending: number
    running: number
    success: number
    failed: number
    exists: number
  }
}

type AutoRegisterStore = AutoRegisterState & AutoRegisterActions

export const useAutoRegisterStore = create<AutoRegisterStore>()((set, get) => ({
  // 初始状态
  accounts: [],
  isRunning: false,
  logs: [],
  concurrency: 3,
  skipOutlookActivation: false,
  shouldStop: false,

  // 添加账号
  addAccounts: (newAccounts) => {
    set((state) => ({
      accounts: [...state.accounts, ...newAccounts]
    }))
  },

  // 清空账号
  clearAccounts: () => {
    if (get().isRunning) return
    set({ accounts: [], logs: [] })
  },

  // 更新账号状态
  updateAccountStatus: (id, updates) => {
    set((state) => ({
      accounts: state.accounts.map(acc =>
        acc.id === id ? { ...acc, ...updates } : acc
      )
    }))
  },

  // 添加日志
  addLog: (message) => {
    const timestamp = new Date().toLocaleTimeString()
    set((state) => ({
      logs: [...state.logs, `[${timestamp}] ${message}`]
    }))
  },

  // 清空日志
  clearLogs: () => {
    set({ logs: [] })
  },

  // 设置运行状态
  setIsRunning: (running) => {
    set({ isRunning: running })
  },

  // 设置并发数
  setConcurrency: (concurrency) => {
    set({ concurrency: Math.min(10, Math.max(1, concurrency)) })
  },

  // 设置跳过 Outlook 激活
  setSkipOutlookActivation: (skip) => {
    set({ skipOutlookActivation: skip })
  },

  // 请求停止
  requestStop: () => {
    set({ shouldStop: true })
  },

  // 重置停止标志
  resetStop: () => {
    set({ shouldStop: false })
  },

  // 获取统计
  getStats: () => {
    const accounts = get().accounts
    return {
      total: accounts.length,
      pending: accounts.filter(a => a.status === 'pending').length,
      running: accounts.filter(a => a.status === 'registering' || a.status === 'activating').length,
      success: accounts.filter(a => a.status === 'success').length,
      failed: accounts.filter(a => a.status === 'failed').length,
      exists: accounts.filter(a => a.status === 'exists').length
    }
  }
}))
