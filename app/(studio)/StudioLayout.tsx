'use client'

import { useAppContext } from '../context/app-context'
import { useRouter } from 'next/navigation'
import { useEffect } from 'react'
import SideNav from '../ui/transverse-components/SideNavigation'
import Box from '@mui/material/Box'

export default function StudioLayout({ children }: { children: React.ReactNode }) {
  const { appContext } = useAppContext()
  const router = useRouter()

  useEffect(() => {
    if (appContext && !appContext.isLoading && !appContext.userID) {
      router.push('/')
    }
  }, [appContext, router])

  if (!appContext || appContext.isLoading || !appContext.userID) {
    return null
  }

  return (
    <Box sx={{ display: 'flex' }}>
      <SideNav />
      {children}
    </Box>
  )
}
